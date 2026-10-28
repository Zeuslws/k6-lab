$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
# Refresh PATH for installations completed after this session started.
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not (Get-Command k6 -ErrorAction SilentlyContinue)) {
    throw 'Install k6 first: winget install k6 --source winget. Then reopen PowerShell.'
}
New-Item -ItemType Directory -Force reports | Out-Null
k6 version | Out-File reports/k6-version.txt -Encoding utf8
'Step,ExitCode' | Set-Content reports/exit-codes.csv -Encoding utf8

function Run-Test {
    param([string]$Name, [string]$Script, [string[]]$Extra = @(), [switch]$Html)
    $arguments = @('run', '--summary-export', "reports/$Name.json")
    if ($Html) { $arguments += @('--out', "web-dashboard=export=reports/$Name.html", '--out', "json=reports/$Name-timeseries.json") }
    $arguments += $Extra
    $arguments += $Script
    Write-Host "Running $Name" -ForegroundColor Cyan
    # Windows PowerShell 5 wraps native stderr as ErrorRecord objects.
    # Preserve expected k6 threshold diagnostics without stopping the pipeline.
    $ErrorActionPreference = 'Continue'
    & k6 @arguments 2>&1 | Tee-Object -FilePath "reports/$Name.log"
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    "$Name,$code" | Add-Content reports/exit-codes.csv
    if ($code -ne 0 -and $code -ne 99) { throw "$Name could not complete; see reports/$Name.log" }
    if ($Name -eq 'a1-smoke' -and $code -ne 0) { throw 'Smoke failed. Fix it before running larger tests.' }
}

# Sequential execution: never combine the loads of different tests.
Run-Test '0.1' '01-first-test.js'
Run-Test '0.2' '01-first-test.js' @('--vus','5','--duration','20s')
Run-Test '0.3' '01-first-test.js' @('--vus','5','--iterations','20')
Run-Test '0.4' '04-pizza-api.js'
Run-Test '0.5' '05-no-token.js'
Run-Test '0.6-normal' '06-thresholds.js'
Run-Test '0.6-strict' '06-thresholds.js' @('-e','P95=300')
Run-Test '0.7-normal' '07-requirement.js'
Run-Test '0.7-strict' '07-requirement.js' @('-e','P95=1')
Run-Test '0.8-original' '08-bug-hunt.js' @('-e','ORIGINAL=1','--vus','5','--duration','20s')
Run-Test 'explore' 'explore.js'
Run-Test '0.8-fixed' '08-bug-hunt.js' @('--vus','5','--duration','20s')
Run-Test 'a1-smoke' 'a1-smoke.js'
Run-Test 'a2-average' 'a2-average.js' -Html
Run-Test 'a3-stress' 'a3-stress.js' -Html
Run-Test 'a4-spike' 'a4-spike.js' -Html
Run-Test 'a5-soak' 'a5-soak.js' -Html

# This extra evidence table is generated only from real k6 summary exports.
@('# Measured Part A results', '', '| Step | Users | Req/s | p(95), ms | Max, ms | Failed, % | Checks, % |',
  '| --- | --- | --- | --- | --- | --- | --- |') | Set-Content reports/measured-results.md
$names = @('a1-smoke','a2-average','a3-stress','a4-spike','a5-soak')
$users = @(1,3,5,5,2)
for ($i = 0; $i -lt $names.Count; $i++) {
    $m = (Get-Content "reports/$($names[$i]).json" -Raw | ConvertFrom-Json).metrics
    $row = '| {0} | {1} | {2:F3} | {3:F2} | {4:F2} | {5:F2} | {6:F2} |' -f $names[$i], $users[$i], $m.http_reqs.rate, $m.http_req_duration.'p(95)', $m.http_req_duration.max, (100 * $m.http_req_failed.value), (100 * $m.checks.value)
    $row | Add-Content reports/measured-results.md
}
Write-Host 'Finished. Use reports/measured-results.md, the logs, and HTML charts to finish RESULTS.md.' -ForegroundColor Green

