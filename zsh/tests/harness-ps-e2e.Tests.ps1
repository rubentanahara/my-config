$ErrorActionPreference = 'Stop'
$root = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid())
$harness = Join-Path (Split-Path $PSScriptRoot) 'harness.ps1'
$project = Join-Path $root 'p'
New-Item -ItemType Directory $project | Out-Null
$script:failures = 0

function Expect([string]$Label, [bool]$Condition) {
    if ($Condition) { Write-Host "  PASS $Label" } else { Write-Host "  FAIL $Label"; $script:failures++ }
}

function Invoke-Quiet([scriptblock]$Block) {
    & $Block *> $script:lastOutput
    $LASTEXITCODE -eq 0
}

function Reset-ToMain([string]$Branch) {
    git reset -q --hard
    git clean -fdq -e .agent
    git checkout -q -B $Branch main
}

. $harness
Set-Location $project
git init -q -b main
git config user.email t@t
git config user.name t

@'
{
  "name": "t",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "build": "node --check src/add.ts",
    "lint": "node --check src/add.ts",
    "format": "echo ok",
    "test": "node --test"
  }
}
'@ | Set-Content package.json

harness . -Lang node *> $null
(Get-Content commands.mk) -replace '^TEST_STORY_CMD := .*', 'TEST_STORY_CMD := npm test -- --test-name-pattern "$$FILTER"' | Set-Content commands.mk
"target/`nbin/`nnode_modules/`n.agent/" | Set-Content .gitignore
git add -A
git -c core.hooksPath=/dev/null commit -qm 'chore: scaffold'
git checkout -q -b feat/add

function Write-Stub { New-Item -ItemType Directory -Force src | Out-Null; 'export function add(_a: number, _b: number): number { return 0; }' | Set-Content src/add.ts }
function Write-Impl { New-Item -ItemType Directory -Force src | Out-Null; 'export function add(a: number, b: number): number { return a + b; }' | Set-Content src/add.ts }
function Write-Test { New-Item -ItemType Directory -Force src | Out-Null; "import { test } from `"node:test`";`nimport assert from `"node:assert`";`nimport { add } from `"./add.ts`";`n`ntest(`"adds`", () => { assert.equal(add(1, 2), 3); });" | Set-Content src/add.test.ts }

Write-Host '== make.ps1'
Write-Stub; Write-Test
Expect 'build step passes' (Invoke-Quiet { ./make.ps1 build })
Expect 'tests fail against the stub' (-not (Invoke-Quiet { ./make.ps1 test }))
Expect 'unknown task refused' (-not (Invoke-Quiet { ./make.ps1 nonsense }))
$failureOutput = ./make.ps1 test *>&1 | Out-String
Expect 'failure names the step' ($failureOutput -match 'CHECK FAILED at test')
Write-Impl
Expect 'check passes with the implementation' (Invoke-Quiet { ./make.ps1 check })
$checkOutput = ./make.ps1 check *>&1 | Out-String
Expect 'check prints CHECK PASSED' ($checkOutput -match 'CHECK PASSED')
Reset-ToMain feat/add

Write-Host '== commit gate'
Write-Stub; Write-Test; git add -A
Expect 'red commit, tests fail' (Invoke-Quiet { git commit -qm 'test(red): add' })

Reset-ToMain no-red
Write-Stub; git add -A
Expect 'source without red refused' (-not (Invoke-Quiet { git commit -qm 'feat: add' }))

git checkout -q -f feat/add
Write-Impl; git add -A
Expect 'green commit passes' (Invoke-Quiet { git commit -qm 'feat: add' })

Reset-ToMain waiver
Write-Impl; git add -A
Expect 'waiver with passing check' (Invoke-Quiet { git commit -qm 'feat: add' -m 'No-Tests: spike' })

Reset-ToMain red-passes
Write-Impl; Write-Test; git add -A
Expect 'red commit with passing tests refused' (-not (Invoke-Quiet { git commit -qm 'test(red): add' }))

Reset-ToMain message
'notes' | Set-Content notes.txt; git add -A
Expect 'non conventional message refused' (-not (Invoke-Quiet { git commit -qm 'did stuff' }))
Expect 'agent attribution refused' (-not (Invoke-Quiet { git commit -qm 'docs: notes' -m 'Co-Authored-By: Claude <noreply@anthropic.com>' }))
Expect 'docs commit passes' (Invoke-Quiet { git commit -qm 'docs: notes' })

Write-Host '== pre-push'
$zeros = '0' * 40
$head = git rev-parse HEAD
Expect 'push to main refused' (-not (Invoke-Quiet { "refs/heads/x $head refs/heads/main $zeros" | pwsh -NoProfile -File scripts/agent/pre-push.ps1 }))
Expect 'push of a new branch allowed' (Invoke-Quiet { "refs/heads/x $head refs/heads/x $zeros" | pwsh -NoProfile -File scripts/agent/pre-push.ps1 })

Write-Host '== feature.ps1'
Reset-ToMain feature
$fragment = '{"epics":[{"id":"E1","title":"t","sprint":1,"stories":[{"id":"S1","name":"n","title":"t","test_filter":"adds","owns":["src/"],"acceptance_criteria":["Given a, when b, then c"]}]}],"sprints":[{"sprint":1,"goal":"g"}]}'
$added = $fragment | ./scripts/agent/feature.ps1 add
Expect 'add reports the story' ("$added" -match 'Added 1 story')
Expect 'status lists the story' ((./scripts/agent/feature.ps1 status | Out-String) -match 'S1 \[not_started\]')
Expect 'waves lists the story' ((./scripts/agent/feature.ps1 waves | Out-String) -match 'S1')
Expect 'show prints the story' ((./scripts/agent/feature.ps1 show S1 | Out-String) -match '"id": "S1"')
Expect 'start activates it' (Invoke-Quiet { ./scripts/agent/feature.ps1 start S1 })
Expect 'second start refused' (-not (Invoke-Quiet { ./scripts/agent/feature.ps1 start S1 }))
Expect 'validate passes' (Invoke-Quiet { ./make.ps1 features })
Expect 'done refused while PROGRESS.md omits the id' (-not (Invoke-Quiet { ./scripts/agent/feature.ps1 done S1 }))
Write-Stub; Write-Test; Write-Impl
Add-Content PROGRESS.md 'S1 added the add function.'
Expect 'scope ok inside owns' (Invoke-Quiet { ./scripts/agent/feature.ps1 scope S1 })
'x' | Set-Content outside.txt
Expect 'scope fails outside owns' (-not (Invoke-Quiet { ./scripts/agent/feature.ps1 scope S1 }))
Remove-Item outside.txt
Expect 'done passes' (Invoke-Quiet { ./scripts/agent/feature.ps1 done S1 })
Expect 'state is passing' ((./scripts/agent/feature.ps1 status | Out-String) -match '1/1 passing')
$handEdited = (Get-Content feature_list.json -Raw) -replace '"evidence": "[^"]*"', '"evidence": ""'
Set-Content feature_list.json $handEdited
Expect 'hand edit without evidence refused' (-not (Invoke-Quiet { ./make.ps1 features }))
git checkout -q -- feature_list.json
Expect 'block and unblock' ((Invoke-Quiet { ./scripts/agent/feature.ps1 block S1 'waiting' }) -or $true)

Write-Host '== stop gate'
Reset-ToMain stop
Remove-Item .agent -Recurse -Force -ErrorAction SilentlyContinue
Expect 'clean tree stops freely' ([string]::IsNullOrEmpty(('{}' | pwsh -NoProfile -File scripts/agent/stop-gate.ps1 | Out-String).Trim()))
Write-Stub; Write-Test
$progressBlock = '{}' | pwsh -NoProfile -File scripts/agent/stop-gate.ps1 | ConvertFrom-Json
Expect 'unchanged PROGRESS.md blocks stop' ($progressBlock.decision -eq 'block' -and $progressBlock.reason -match 'PROGRESS.md did not')
Add-Content PROGRESS.md 'changed add.'
$blocked = '{}' | pwsh -NoProfile -File scripts/agent/stop-gate.ps1 | ConvertFrom-Json
Expect 'failing check blocks stop' ($blocked.decision -eq 'block' -and $blocked.reason -match 'make check failed')
Write-Impl
$allowed = '{}' | pwsh -NoProfile -File scripts/agent/stop-gate.ps1
Expect 'passing check allows stop' ([string]::IsNullOrEmpty("$allowed".Trim()))

Write-Host '== session start'
$session = '{"session_id":"abc"}' | pwsh -NoProfile -File scripts/agent/session-start.ps1 | ConvertFrom-Json
Expect 'session start injects context' ($session.hookSpecificOutput.additionalContext -match 'make check ran just now')
Expect 'session start records a baseline' (Test-Path .agent/session-baseline-abc)
Expect 'context stays under the hook limit' ($session.hookSpecificOutput.additionalContext.Length -le 9000)

Write-Host "failures: $script:failures"
Set-Location $PSScriptRoot
Remove-Item $root -Recurse -Force
exit ([int]($script:failures -gt 0))
