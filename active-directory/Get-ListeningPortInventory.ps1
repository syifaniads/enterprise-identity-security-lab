[CmdletBinding()]
param(
    [Parameter()]
    [string[]]$ComputerName = @($env:COMPUTERNAME),

    [Parameter()]
    [string]$CsvPath
)

$Report = foreach ($Computer in $ComputerName) {
    try {
        Invoke-Command -ComputerName $Computer -ErrorAction Stop -ScriptBlock {
            Get-NetTCPConnection -State Listen | ForEach-Object {
                $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
                [pscustomobject]@{
                    ComputerName  = $env:COMPUTERNAME
                    LocalAddress  = $_.LocalAddress
                    LocalPort     = $_.LocalPort
                    ProcessId     = $_.OwningProcess
                    ProcessName   = $proc.ProcessName
                    ProcessPath   = $proc.Path
                    State         = $_.State
                }
            }
        }
    }
    catch {
        [pscustomobject]@{
            ComputerName = $Computer
            LocalAddress = $null
            LocalPort    = $null
            ProcessId    = $null
            ProcessName  = $null
            ProcessPath  = $null
            State        = "ERROR: $($_.Exception.Message)"
        }
    }
}

$Report = @($Report)
if ($CsvPath) { $Report | Export-Csv -LiteralPath $CsvPath -NoTypeInformation -Encoding UTF8 }
$Report
