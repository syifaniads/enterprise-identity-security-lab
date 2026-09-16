BeforeAll {
    $RepoRoot = Split-Path -Parent $PSScriptRoot
    $ActiveDirectoryPath = Join-Path $RepoRoot 'active-directory'
    $ImportScriptPath = Join-Path $ActiveDirectoryPath 'Import-ADUsers.ps1'
}

Describe 'PowerShell source quality' {
    It 'contains at least one PowerShell artifact' {
        @(Get-ChildItem -Path $ActiveDirectoryPath -Filter '*.ps1' -File).Count | Should -BeGreaterThan 0
    }

    It 'all PowerShell artifacts parse without syntax errors' {
        $Failures = [System.Collections.Generic.List[string]]::new()

        foreach ($Script in Get-ChildItem -Path $ActiveDirectoryPath -Filter '*.ps1' -File) {
            $Tokens = $null
            $Errors = $null
            [System.Management.Automation.Language.Parser]::ParseFile(
                $Script.FullName,
                [ref]$Tokens,
                [ref]$Errors
            ) | Out-Null

            foreach ($ParseError in @($Errors)) {
                $Failures.Add("$($Script.Name): $($ParseError.Message)")
            }
        }

        $Failures | Should -BeNullOrEmpty
    }

    It 'contains no historical domain names or obvious plaintext password assignments' {
        foreach ($Script in Get-ChildItem -Path $ActiveDirectoryPath -Filter '*.ps1' -File) {
            $Content = Get-Content -LiteralPath $Script.FullName -Raw
            $Content | Should -Not -Match '(?i)diaas\.in|efs\.edu'
            $Content | Should -Not -Match '(?i)password\s*=\s*["''][^$]'
        }
    }
}

Describe 'Provisioning safeguards' {
    It 'uses SupportsShouldProcess' {
        $ImportScript = Get-Content -LiteralPath $ImportScriptPath -Raw
        $ImportScript | Should -Match 'SupportsShouldProcess\s*=\s*\$true'
    }

    It 'sets the target AD Path explicitly' {
        $ImportScript = Get-Content -LiteralPath $ImportScriptPath -Raw
        $ImportScript | Should -Match 'Path\s*=\s*\$TargetOU'
    }

    It 'does not read a password column from CSV' {
        $ImportScript = Get-Content -LiteralPath $ImportScriptPath -Raw
        $ImportScript | Should -Not -Match '\$User\.password'
    }
}
