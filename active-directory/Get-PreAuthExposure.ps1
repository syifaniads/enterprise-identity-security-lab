#Requires -Modules ActiveDirectory
[CmdletBinding()]
param(
    [Parameter()]
    [string[]]$SearchBase,

    [Parameter()]
    [string]$CsvPath
)

Import-Module ActiveDirectory -ErrorAction Stop
$bases = if ($SearchBase) { $SearchBase } else { @((Get-ADDomain).DistinguishedName) }
$Result = foreach ($Base in $bases) {
    Get-ADUser -Filter { Enabled -eq $true -and DoesNotRequirePreAuth -eq $true } `
        -SearchBase $Base -Properties DoesNotRequirePreAuth, LastLogonDate, Description |
        Select-Object Name, SamAccountName, DistinguishedName, DoesNotRequirePreAuth, LastLogonDate, Description
}

$Result = @($Result)
if ($CsvPath) { $Result | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8 }
$Result
