#Requires -Modules ActiveDirectory
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [string]$SearchBase,

    [Parameter()]
    [ValidateRange(30, 3650)]
    [int]$InactiveDays = 90,

    [Parameter()]
    [string[]]$ProtectedGroups = @('Domain Admins','Enterprise Admins','Schema Admins'),

    [Parameter()]
    [switch]$DisableCandidates,

    [Parameter()]
    [string]$CsvPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory -ErrorAction Stop

Get-ADOrganizationalUnit -Identity $SearchBase -ErrorAction Stop | Out-Null
$Cutoff = (Get-Date).AddDays(-$InactiveDays)

$Users = Get-ADUser -Filter { Enabled -eq $true } -SearchBase $SearchBase `
    -Properties LastLogonDate, whenCreated, ServicePrincipalName, adminCount, Description

$Candidates = foreach ($User in $Users) {
    $ReasonsToExclude = [System.Collections.Generic.List[string]]::new()

    if ($User.ServicePrincipalName.Count -gt 0) { $ReasonsToExclude.Add('SPN-bearing account') }
    if ($User.adminCount -eq 1) { $ReasonsToExclude.Add('adminCount=1') }

    try {
        $Membership = @(Get-ADPrincipalGroupMembership -Identity $User | Select-Object -ExpandProperty Name)
        foreach ($Group in $ProtectedGroups) {
            if ($Group -in $Membership) { $ReasonsToExclude.Add("Protected group: $Group") }
        }
    }
    catch {
        $ReasonsToExclude.Add('Could not resolve group membership')
    }

    $LastSeen = $User.LastLogonDate
    $OldEnough = $User.whenCreated -lt $Cutoff
    $Inactive = (($null -eq $LastSeen -and $OldEnough) -or ($null -ne $LastSeen -and $LastSeen -lt $Cutoff))

    if ($Inactive) {
        [pscustomobject]@{
            SamAccountName    = $User.SamAccountName
            DistinguishedName = $User.DistinguishedName
            LastLogonDate     = $LastSeen
            Created           = $User.whenCreated
            InactiveDays      = $InactiveDays
            Excluded          = ($ReasonsToExclude.Count -gt 0)
            ExclusionReason   = ($ReasonsToExclude -join '; ')
        }
    }
}

$Candidates = @($Candidates)
if ($CsvPath) {
    $Candidates | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8
}

$Candidates

if ($DisableCandidates) {
    foreach ($Candidate in $Candidates | Where-Object { -not $_.Excluded }) {
        if ($PSCmdlet.ShouldProcess($Candidate.SamAccountName, 'Disable inactive AD account')) {
            Disable-ADAccount -Identity $Candidate.DistinguishedName -ErrorAction Stop
        }
    }
}

Write-Warning 'LastLogonDate is derived from replicated lastLogonTimestamp and is suitable for coarse inactivity review, not exact last-login forensics.'
