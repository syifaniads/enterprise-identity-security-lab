$RepoRoot = Split-Path -Parent $PSScriptRoot
$Scripts = Get-ChildItem -Path (Join-Path $RepoRoot 'active-directory') -Filter '*.ps1' -File

Describe 'PowerShell source quality' {
    It 'contains at least one PowerShell artifact' {
        $Scripts.Count | Should -BeGreaterThan 0
    }

    foreach ($Script in $Scripts) {
        It "$($Script.Name) parses without syntax errors" {
            $tokens = $null
            $errors = $null
            [System.Management.Automation.Language.Parser]::ParseFile($Script.FullName, [ref]$tokens, [ref]$errors) | Out-Null
            $errors | Should -BeNullOrEmpty
        }

        It "$($Script.Name) contains no historical domain names or obvious password assignments" {
            $content = Get-Content -LiteralPath $Script.FullName -Raw
            $content | Should -Not -Match '(?i)diaas\.in|efs\.edu'
            $content | Should -Not -Match '(?i)password\s*=\s*["''][^$]'
        }
    }
}

Describe 'Provisioning safeguards' {
    $ImportScript = Get-Content -LiteralPath (Join-Path $RepoRoot 'active-directory/Import-ADUsers.ps1') -Raw

    It 'uses SupportsShouldProcess' {
        $ImportScript | Should -Match 'SupportsShouldProcess\s*=\s*\$true'
    }

    It 'sets the target AD Path explicitly' {
        $ImportScript | Should -Match 'Path\s*=\s*\$TargetOU'
    }

    It 'does not read a password column from CSV' {
        $ImportScript | Should -Not -Match '\$User\.password'
    }
}
