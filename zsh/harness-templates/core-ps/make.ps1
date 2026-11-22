param(
    [Parameter(Position = 0)][string]$Task = 'check',
    [string]$Filter
)

$logs = '.agent'
$stepTail = @{ build = 20; lint = 20; test = 40 }

function Read-Commands {
    $commands = @{}
    foreach ($line in Get-Content (Join-Path $PSScriptRoot 'commands.mk')) {
        if ($line -match '^([A-Z_]+) := (.*)$') { $commands[$Matches[1]] = $Matches[2] }
    }
    $commands
}

function Invoke-CommandLine([string]$CommandLine) {
    $env:FILTER = $Filter
    $global:LASTEXITCODE = 0
    Invoke-Expression ($CommandLine -replace '\$\$FILTER', '$env:FILTER')
}

function Step-Fails([string]$Name, [string]$CommandName, [string]$Hint) {
    New-Item -ItemType Directory -Force $logs | Out-Null
    $log = "$logs/$Name.log"
    $global:LASTEXITCODE = 0
    $succeeded = $true
    try {
        $commandLine = (Read-Commands)[$CommandName]
        Invoke-CommandLine $commandLine *> $log
        $succeeded = $LASTEXITCODE -eq 0
    } catch {
        $_ | Out-File $log -Append
        $succeeded = $false
    }
    if ($succeeded) { Write-Host "OK   $Name"; return $false }
    Get-Content $log -Tail $stepTail[$Name] | ForEach-Object { Write-Host $_ }
    Write-Host "CHECK FAILED at $Name. $Hint"
    $true
}

function Invoke-Build { if (Step-Fails 'build' 'BUILD_CMD' "Full log in $logs/build.log. Fix the errors, then run ./make.ps1 check.") { exit 1 } }
function Invoke-Lint { if (Step-Fails 'lint' 'LINT_CMD' 'Run ./make.ps1 format to fix it automatically, then run ./make.ps1 check.') { exit 1 } }
function Invoke-Test {
    Invoke-Build
    if (Step-Fails 'test' 'TEST_CMD' "Full log in $logs/test.log. Fix the code, not the test, unless the test is wrong.") { exit 1 }
}

function Invoke-Hooks {
    jq -n -e --slurpfile claude .claude/settings.json --slurpfile codex .codex/hooks.json '$claude[0].hooks != null and $claude[0].hooks == $codex[0].hooks' *> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "CHECK FAILED at hooks. .codex/hooks.json differs from the hooks in .claude/settings.json. Edit .claude/settings.json, then run: jq '{hooks}' .claude/settings.json > .codex/hooks.json"
        exit 1
    }
    Write-Host 'OK   hooks'
}

function Invoke-Features {
    New-Item -ItemType Directory -Force $logs | Out-Null
    & "$PSScriptRoot/scripts/agent/feature.ps1" validate *> "$logs/features.log"
    if ($LASTEXITCODE -ne 0) {
        Get-Content "$logs/features.log" | ForEach-Object { Write-Host $_ }
        Write-Host 'CHECK FAILED at features. Change feature_list.json only through scripts/agent/feature.ps1.'
        exit 1
    }
    Write-Host 'OK   features'
}

function Invoke-Setup {
    git config core.hooksPath .husky
    Invoke-CommandLine ((Read-Commands).INSTALL_CMD)
    foreach ($tool in 'gitleaks', 'jq') {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { Write-Host "WARNING: $tool is not installed; $(if ($tool -eq 'gitleaks') { 'the pre-commit hook needs it' } else { 'make check and the scripts in scripts/agent need it' })." }
    }
    Write-Host 'OK   setup. Run ./make.ps1 check next.'
}

switch ($Task) {
    'check' {
        Invoke-Hooks; Invoke-Features; Invoke-Build; Invoke-Lint; Invoke-Test
        Write-Host 'CHECK PASSED: hooks, features, build, lint, tests'
    }
    'setup' { Invoke-Setup }
    'build' { Invoke-Build }
    'lint' { Invoke-Lint }
    'test' { Invoke-Test }
    'test-story' {
        if (-not $Filter) { Write-Host 'Pass a filter: ./make.ps1 test-story -Filter <filter>'; exit 1 }
        Invoke-Build
        Invoke-CommandLine ((Read-Commands).TEST_STORY_CMD)
        exit $LASTEXITCODE
    }
    'format' { Invoke-CommandLine ((Read-Commands).FORMAT_CMD); Write-Host 'OK   format' }
    'run' { Invoke-CommandLine ((Read-Commands).RUN_CMD) }
    'hooks' { Invoke-Hooks }
    'features' { Invoke-Features }
    'clean' { Remove-Item $logs -Recurse -Force -ErrorAction SilentlyContinue; Write-Host 'OK   clean' }
    default { Write-Host "Unknown task '$Task'. Tasks: check setup build lint test test-story format run hooks features clean"; exit 1 }
}
exit 0
