#Requires -Modules ActiveDirectory
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SearchBase,

    [Parameter()]
    [string]$CsvPath
)

Import-Module ActiveDirectory -ErrorAction Stop
Get-ADOrganizationalUnit -Identity $SearchBase -ErrorAction Stop | Out-Null

$Result = Get-ADGroup -Filter * -SearchBase $SearchBase -Properties Members, Description, whenCreated, whenChanged, ManagedBy |
    Where-Object { $_.Members.Count -eq 0 } |
    Select-Object Name, DistinguishedName, GroupCategory, GroupScope, ManagedBy, Description, whenCreated, whenChanged

if ($CsvPath) { $Result | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8 }
$Result
Write-Warning 'This is an inventory only. Empty membership does not prove a group is safe to delete; review ACL/GPO/application references and ownership first.'
