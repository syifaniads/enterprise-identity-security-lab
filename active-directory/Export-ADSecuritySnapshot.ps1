#Requires -Modules ActiveDirectory
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$OutputPath
)

Import-Module ActiveDirectory -ErrorAction Stop
$Domain = Get-ADDomain
$Guest = Get-ADUser -Filter { SamAccountName -eq 'Guest' } -Properties Enabled -ErrorAction SilentlyContinue

$Snapshot = [ordered]@{
    collectedAt = (Get-Date).ToUniversalTime().ToString('o')
    domain = [ordered]@{
        dnsRoot = $Domain.DNSRoot
        forest = $Domain.Forest
        domainMode = [string]$Domain.DomainMode
    }
    domainControllers = @(Get-ADDomainController -Filter * | Select-Object HostName, Site, IPv4Address, IsGlobalCatalog)
    defaultPasswordPolicy = Get-ADDefaultDomainPasswordPolicy | Select-Object ComplexityEnabled, LockoutDuration, LockoutObservationWindow, LockoutThreshold, MaxPasswordAge, MinPasswordAge, MinPasswordLength, PasswordHistoryCount, ReversibleEncryptionEnabled
    fineGrainedPasswordPolicies = @(Get-ADFineGrainedPasswordPolicy -Filter * | Select-Object Name, Precedence, MinPasswordLength, MaxPasswordAge, PasswordHistoryCount, LockoutThreshold, LockoutDuration, ComplexityEnabled, ReversibleEncryptionEnabled)
    guestAccount = if ($Guest) { $Guest | Select-Object SamAccountName, Enabled, DistinguishedName } else { $null }
    passwordNotRequired = @(Get-ADUser -Filter { Enabled -eq $true -and PasswordNotRequired -eq $true } | Select-Object SamAccountName, DistinguishedName)
    preAuthDisabled = @(Get-ADUser -Filter { Enabled -eq $true -and DoesNotRequirePreAuth -eq $true } | Select-Object SamAccountName, DistinguishedName)
}

$Parent = Split-Path -Path $OutputPath -Parent
if ($Parent -and -not (Test-Path -LiteralPath $Parent)) {
    New-Item -ItemType Directory -Path $Parent -Force | Out-Null
}

$Snapshot | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
$Snapshot
