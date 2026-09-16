#Requires -Modules ActiveDirectory
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$CsvPath,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$UpnSuffix = 'lab.example',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$DefaultOU = 'OU=Users,OU=Lab,DC=lab,DC=example',

    [Parameter()]
    [SecureString]$TemporaryPassword,

    [Parameter()]
    [switch]$EnableAfterCreate,

    [Parameter()]
    [string]$LogPath = (Join-Path $PWD ("Import-ADUsers-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss')))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory -ErrorAction Stop

$RequiredColumns = @('username', 'firstname', 'lastname', 'email', 'department', 'ou')

function Write-AuditLog {
    param([string]$Message, [ValidateSet('INFO','WARN','ERROR')][string]$Level = 'INFO')
    $line = '[{0}] [{1}] {2}' -f (Get-Date -Format o), $Level, $Message
    Add-Content -LiteralPath $LogPath -Value $line
    Write-Verbose $line
}

if ($EnableAfterCreate -and -not $TemporaryPassword) {
    throw 'EnableAfterCreate requires -TemporaryPassword as a SecureString. Passwords are intentionally not read from CSV.'
}

$Users = @(Import-Csv -LiteralPath $CsvPath -Delimiter ';')
if ($Users.Count -eq 0) {
    throw 'CSV contains no data rows.'
}

$Headers = @($Users[0].PSObject.Properties.Name)
$Missing = @($RequiredColumns | Where-Object { $_ -notin $Headers })
if ($Missing.Count -gt 0) {
    throw "CSV is missing required column(s): $($Missing -join ', ')"
}

$Seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$Results = [System.Collections.Generic.List[object]]::new()

foreach ($User in $Users) {
    $Username = [string]$User.username
    if ([string]::IsNullOrWhiteSpace($Username)) {
        Write-AuditLog 'Skipped row with empty username.' 'WARN'
        continue
    }

    if (-not $Seen.Add($Username)) {
        Write-AuditLog "Duplicate username '$Username' exists in the input file; skipped." 'WARN'
        $Results.Add([pscustomobject]@{ Username=$Username; Status='Skipped'; Reason='Duplicate input username' })
        continue
    }

    $TargetOU = if ([string]::IsNullOrWhiteSpace([string]$User.ou)) { $DefaultOU } else { [string]$User.ou }

    try {
        Get-ADOrganizationalUnit -Identity $TargetOU -ErrorAction Stop | Out-Null
    }
    catch {
        Write-AuditLog "OU '$TargetOU' does not exist for '$Username'; skipped." 'ERROR'
        $Results.Add([pscustomobject]@{ Username=$Username; Status='Failed'; Reason='Target OU not found' })
        continue
    }

    $Existing = Get-ADUser -Filter { SamAccountName -eq $Username } -ErrorAction Stop
    if ($Existing) {
        Write-AuditLog "User '$Username' already exists; skipped." 'WARN'
        $Results.Add([pscustomobject]@{ Username=$Username; Status='Skipped'; Reason='Already exists' })
        continue
    }

    $UserParams = @{
        SamAccountName        = $Username
        UserPrincipalName     = "$Username@$UpnSuffix"
        Name                  = ("{0} {1}" -f $User.firstname, $User.lastname).Trim()
        GivenName             = [string]$User.firstname
        Surname               = [string]$User.lastname
        Initials              = [string]$User.initials
        DisplayName           = ("{0} {1}" -f $User.firstname, $User.lastname).Trim()
        City                  = [string]$User.city
        PostalCode            = [string]$User.zipcode
        Country               = [string]$User.country
        Company               = [string]$User.company
        State                 = [string]$User.state
        StreetAddress         = [string]$User.streetaddress
        OfficePhone           = [string]$User.telephone
        EmailAddress          = [string]$User.email
        Title                 = [string]$User.jobtitle
        Department            = [string]$User.department
        Path                  = $TargetOU
        Enabled               = [bool]$EnableAfterCreate
        ChangePasswordAtLogon = [bool]$EnableAfterCreate
        ErrorAction           = 'Stop'
    }

    if ($TemporaryPassword) {
        $UserParams.AccountPassword = $TemporaryPassword
    }

    if ($PSCmdlet.ShouldProcess("$Username in $TargetOU", 'Create Active Directory user')) {
        try {
            New-ADUser @UserParams
            Write-AuditLog "Created '$Username' in '$TargetOU'. Enabled=$([bool]$EnableAfterCreate)."
            $Results.Add([pscustomobject]@{ Username=$Username; Status='Created'; Reason='' })
        }
        catch {
            Write-AuditLog "Failed to create '$Username': $($_.Exception.Message)" 'ERROR'
            $Results.Add([pscustomobject]@{ Username=$Username; Status='Failed'; Reason=$_.Exception.Message })
        }
    }
}

$Results
