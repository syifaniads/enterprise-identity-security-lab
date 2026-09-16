#Requires -Modules ActiveDirectory
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [Parameter()]
    [string]$DomainDN = 'DC=lab,DC=example',

    [Parameter()]
    [string]$RootOUName = 'Lab'
)

Import-Module ActiveDirectory -ErrorAction Stop
$RootDN = "OU=$RootOUName,$DomainDN"

function Ensure-OU {
    param([string]$Name, [string]$Path)
    $dn = "OU=$Name,$Path"
    if (-not (Get-ADOrganizationalUnit -Identity $dn -ErrorAction SilentlyContinue)) {
        if ($PSCmdlet.ShouldProcess($dn, 'Create organizational unit')) {
            New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
        }
    }
    $dn
}

if (-not (Get-ADOrganizationalUnit -Identity $RootDN -ErrorAction SilentlyContinue)) {
    if ($PSCmdlet.ShouldProcess($RootDN, 'Create root organizational unit')) {
        New-ADOrganizationalUnit -Name $RootOUName -Path $DomainDN -ProtectedFromAccidentalDeletion $true
    }
}

$StudentsOU = Ensure-OU -Name 'Students' -Path $RootDN
$FacultyOU  = Ensure-OU -Name 'Faculty'  -Path $RootDN
$AdminsOU   = Ensure-OU -Name 'Admins'   -Path $RootDN
$AlumniOU   = Ensure-OU -Name 'Alumni'   -Path $RootDN
$GroupsOU   = Ensure-OU -Name 'Groups'   -Path $RootDN

$Groups = @(
    'LAB-Students',
    'LAB-Faculty',
    'LAB-Alumni-Limited',
    'LAB-Password-Reset-Operators',
    'LAB-Identity-Operations',
    'LAB-Privileged-AD-Admins'
)

foreach ($Group in $Groups) {
    if (-not (Get-ADGroup -Filter { SamAccountName -eq $Group } -ErrorAction Stop)) {
        if ($PSCmdlet.ShouldProcess($Group, 'Create global security group')) {
            New-ADGroup -Name $Group -SamAccountName $Group -GroupScope Global -GroupCategory Security -Path $GroupsOU
        }
    }
}

[pscustomobject]@{
    RootOU   = $RootDN
    Students = $StudentsOU
    Faculty  = $FacultyOU
    Admins   = $AdminsOU
    Alumni   = $AlumniOU
    Groups   = $GroupsOU
}
