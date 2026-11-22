$ErrorActionPreference = 'Stop'
$root = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid())
$harness = Join-Path (Split-Path $PSScriptRoot) 'harness.ps1'
$bin = Join-Path $root 'bin'
$project = Join-Path $root 'p'
New-Item -ItemType Directory $bin, $project | Out-Null
$script:failures = 0

function Expect([string]$Label, [bool]$Condition) {
    if ($Condition) { Write-Host "  PASS $Label" } else { Write-Host "  FAIL $Label"; $script:failures++ }
}

foreach ($cli in 'claude', 'codex', 'copilot', 'gemini') {
    $stub = Join-Path $bin $cli
    "#!/bin/sh`nprintf '%s\n' `"`$@`" > '$root/$cli.args'" | Set-Content $stub
    chmod +x $stub
}
$env:PATH = "$bin$([System.IO.Path]::PathSeparator)$env:PATH"
. $harness

Set-Location $project
git init -q -b main
git config user.email t@t
git config user.name t

harness . -Lang node *> $null
Expect 'AGENTS.md copied' (Test-Path AGENTS.md)
Expect 'CLAUDE.md links to AGENTS.md' (Test-Path CLAUDE.md)
Expect 'copilot-instructions links to AGENTS.md' (Test-Path .github/copilot-instructions.md)
Expect 'hooksPath set' ((git config core.hooksPath) -eq '.husky')
Expect '.agent/ ignored' ((Get-Content .gitignore) -contains '.agent/')
Expect 'node commands set in commands.mk' ([bool](Select-String -Path commands.mk -Pattern '^BUILD_CMD := ' | Where-Object { $_.Line -notmatch 'set BUILD_CMD' }))
Expect 'no bash scripts or Makefile copied' (-not ((Test-Path Makefile) -or (Test-Path scripts/agent/feature.sh)))
Expect 'hooks call pwsh' ((Get-Content .claude/settings.json -Raw) -match 'pwsh -NoProfile')
Expect 'docs use PowerShell commands' ((Get-Content AGENTS.md -Raw) -match './make.ps1 check')
Expect 'node setup step in workflow' (Select-String -Path .github/workflows/check.yml -Pattern 'actions/setup-node@v7' -Quiet)
Expect 'empty agent dirs get .gitkeep' (Test-Path .claude/routines/.gitkeep)

harness . -Lang node *> $null
Expect 'setup step not duplicated' ((Select-String -Path .github/workflows/check.yml -Pattern 'setup-node').Count -eq 1)

'keep me' | Set-Content AGENTS.md
harness . *> $null
Expect 'existing file not overwritten' ((Get-Content AGENTS.md) -eq 'keep me')

'stale' | Set-Content scripts/agent/stop-gate.ps1
harness . -Sync *> $null
Expect 'sync restores scripts/agent' (Select-String -Path scripts/agent/stop-gate.ps1 -Pattern 'maxAttempts' -Quiet)

harness . -Fill claude *> $null
Expect 'claude gets the brief' (Select-String -Path "$root/claude.args" -Pattern 'finishing the setup of an agent harness' -Quiet)
Expect 'claude defaults to haiku' ((Get-Content "$root/claude.args") -contains 'haiku')
Expect 'claude runs with acceptEdits' ((Get-Content "$root/claude.args") -contains 'acceptEdits')

harness . -Fill codex *> $null
Expect 'codex defaults to gpt-6-luna' ((Get-Content "$root/codex.args") -contains 'gpt-6-luna')
Expect 'codex runs in workspace-write' ((Get-Content "$root/codex.args") -contains 'workspace-write')

harness . -Fill copilot *> $null
Expect 'copilot defaults to auto' ((Get-Content "$root/copilot.args") -contains 'auto')
Expect 'copilot denies git push' ((Get-Content "$root/copilot.args") -contains '--deny-tool=shell(git push)')

harness . -Fill gemini *> $null
Expect 'gemini defaults to flash-lite' ((Get-Content "$root/gemini.args") -contains 'flash-lite')

harness . -Fill claude -Model opus *> $null
Expect '-Model overrides the default' ((Get-Content "$root/claude.args") -contains 'opus')

$refused = $false
try { harness . -Fill vim *> $null } catch { $refused = $true }
Expect 'unknown cli refused' $refused
Expect 'unknown lang refused' ([bool]((harness . -Lang cobol 6>&1) -match "unknown -Lang 'cobol'"))

Write-Host "failures: $script:failures"
Set-Location $PSScriptRoot
Remove-Item $root -Recurse -Force
exit ([int]($script:failures -gt 0))
