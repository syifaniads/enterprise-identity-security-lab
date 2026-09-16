#Requires -Modules ActiveDirectory
[CmdletBinding()]
param(
    [Parameter()]
    [string]$SearchBase,

    [Parameter()]
    [string]$CsvPath
)

Import-Module ActiveDirectory -ErrorAction Stop
$params = @{
    Filter = { Enabled -eq $true -and PasswordNotRequired -eq $true }
    Properties = @('PasswordNotRequired','LastLogonDate','Description')
}
if ($SearchBase) { $params.SearchBase = $SearchBase }

$Result = Get-ADUser @params | Select-Object Name, SamAccountName, DistinguishedName, PasswordNotRequired, LastLogonDate, Description
if ($CsvPath) { $Result | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8 }
$Result
