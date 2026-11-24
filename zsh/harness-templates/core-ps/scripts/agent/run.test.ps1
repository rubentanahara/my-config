$ErrorActionPreference = 'Stop'
$scriptsDir = $PSScriptRoot
$script:failures = 0

function Assert-Equal([string]$Description, [string]$Expected, [string]$Actual) {
    if ($Actual -eq $Expected) { return }
    Write-Host "FAIL: $Description"
    Write-Host "  expected: $Expected"
    Write-Host "  got:      $Actual"
    $script:failures++
}

function New-Commit([string]$Repo, [string]$Message) {
    git -C $Repo add -A
    git -C $Repo -c user.email=t@t -c user.name=t commit -q --allow-empty -m $Message
}

$sandbox = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid())
$tddRepo = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid())
try {
    New-Item -ItemType Directory -Force "$sandbox/scripts/agent" | Out-Null
    Set-Location $sandbox
    git init -q
    Copy-Item "$scriptsDir/feature.ps1", "$scriptsDir/common.ps1" scripts/agent/
    $jqDirectory = if (Test-Path "$scriptsDir/jq") { "$scriptsDir/jq" } else { "$scriptsDir/../../../core/scripts/agent/jq" }
    Copy-Item $jqDirectory scripts/agent/ -Recurse
    Set-Content feature_list.json @'
{"project_title":"Test","priority_legend":{},"sprints":[{"sprint":1,"goal":"first"}],
 "epics":[{"id":"E1","title":"Epic","sprint":1,"summary":"","stories":[
   {"id":"F05","name":"Create Tag (v2)!","title":"As a user, I want tags","acceptance_criteria":["Given, When, Then"],
    "test_filter":"TagTests","depends_on":[],"owns":["src/Tags/"],"state":"not_started","evidence":""}]}]}
'@

    . "$scriptsDir/run.ps1"
    $script:Root = $sandbox

    Assert-Equal 'branch names are lowercase slugs' 'feat/f05-create-tag-v2' (Get-BranchName F05)
    Assert-Equal 'session names keep the story name' 'F05 · Create Tag (v2)!' (Get-SessionName F05)
    Assert-Equal 'slugs stop at the length limit without a trailing dash' ('a' * 40) (ConvertTo-Slug ('a' * 45))
    Assert-Equal 'agy defaults to gemini 3.8 flash high' 'gemini-3.8-flash-high' $defaultModels['agy']

    Set-Content pass.md "table`n`n**VERIFY: PASS**"
    Set-Content fail.md "VERIFY: FAIL 1 of 3 criteria, 0 other findings`nmore text"
    Set-Content none.md 'no verdict here'
    Set-Content both.md "VERIFY: PASS`nlater it changed its mind`nVERIFY: FAIL 2 of 3 criteria, 1 other findings"
    Assert-Equal 'a bold PASS line counts' 'VERIFY: PASS' (Get-Verdict pass.md)
    Assert-Equal 'a FAIL line keeps its counts' 'VERIFY: FAIL 1 of 3 criteria, 0 other findings' (Get-Verdict fail.md)
    Assert-Equal 'no VERIFY line gives no verdict' '' (Get-Verdict none.md)
    Assert-Equal 'the last VERIFY line wins' 'VERIFY: FAIL 2 of 3 criteria, 1 other findings' (Get-Verdict both.md)

    Save-Result F05 shipped 'https://example/pull/1' 2> $null
    Assert-Equal 'Get-Result reads a matching result' 'https://example/pull/1' (Get-Result F05 shipped)
    Assert-Equal 'Get-Result refuses another outcome' '' (Get-Result F05 blocked)
    Assert-Equal 'a story without a worktree has no worktree state' '' (Get-WorktreeState F05)

    Set-Content stream.jsonl @'
{"type":"system","subtype":"init"}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"src/Tags/tag.go"}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"make test-story FILTER=TagTests\nsecond line"}}]}}
{"type":"result","subtype":"success","result":"Done.\nVERIFY: PASS"}
not json at all
'@
    $streamOut = Join-Path $sandbox '.agent/runs/F05/review-1.md'
    $streamShown = pwsh -NoProfile -Command ". '$scriptsDir/run.ps1'; Get-Content stream.jsonl | Show-ClaudeStream 'F05 · review' '$streamOut'" 2> stream.err
    Assert-Equal 'the stream shows one line per step' 'F05 · review › Read src/Tags/tag.go|F05 · review › Bash make test-story FILTER=TagTests|F05 · review › not json at all' ((Get-Content stream.err) -join '|')
    Assert-Equal 'the stream appends its steps to progress.log' '3' "$((Get-Content (Join-Path $sandbox '.agent/runs/F05/progress.log')).Count)"
    Assert-Equal 'the session output file holds the final text and raw lines' 'Done.|VERIFY: PASS|not json at all' ((Get-Content $streamOut) -join '|')
    Assert-Equal 'the final text is printed' 'Done.|VERIFY: PASS|not json at all' ($streamShown -join '|')
    Assert-Equal 'the raw stream is kept' '5' "$((Get-Content "$streamOut.jsonl").Count)"
    Assert-Equal 'the verdict reads from the final text' 'VERIFY: PASS' (Get-Verdict $streamOut)

    Assert-Equal 'a backgrounded line gives the session id' '9a986fbf' (Get-LiveSessionId @('Starting background service…', 'backgrounded · 9a986fbf · F05 · review'))
    Assert-Equal 'no backgrounded line gives no id' '' (Get-LiveSessionId @('Workspace not trusted.'))
    Assert-Equal '-Live refuses other CLIs' '-Live works with claude only: it opens each session with claude --bg. Use -Cli claude -Checker claude, or drop -Live.' ((pwsh -NoProfile -File "$scriptsDir/run.ps1" -Live -Cli copilot 2>&1) -join '|')

    $claudeHome = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid())
    New-Item -ItemType Directory -Force "$claudeHome/projects/-sandbox" | Out-Null
    Set-Content "$claudeHome/projects/-sandbox/5dbbc910-aaaa.jsonl" @'
{"type":"user","message":{"content":"go"}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"git diff main"}}]}}
{"type":"assistant","isSidechain":true,"message":{"content":[{"type":"text","text":"subagent noise"}]}}
{"type":"assistant","message":{"content":[{"type":"text","text":"Table\nVERIFY: PASS"}]}}
'@
    $liveOut = Join-Path $sandbox '.agent/runs/F05/review-2.md'
    Set-Content live.ps1 @"
. '$scriptsDir/run.ps1'
function claude {
    switch (`$args[0]) {
        'agents' { '[{"id":"5dbbc910","state":"done","sessionId":"5dbbc910-aaaa"}]' }
        'rm' { }
        default { `$args | Set-Content '$sandbox/claude-args'; 'backgrounded · 5dbbc910 · F05 · review' }
    }
}
`$Live = `$true
`$env:CLAUDE_CONFIG_DIR = '$claudeHome'
Remove-Item Env:TMUX -ErrorAction SilentlyContinue
Invoke-Session '$sandbox' claude claude-opus-5-5 read 'F05 · review' 'Review F05' '$liveOut'
"@
    $liveShown = pwsh -NoProfile -File live.ps1 2> live.err
    $claudeArgs = @(Get-Content "$sandbox/claude-args")
    Assert-Equal 'a live session starts in the background' 'True' "$($claudeArgs -contains '--bg')"
    Assert-Equal 'a live review never waits on a prompt' 'dontAsk' $claudeArgs[[array]::IndexOf($claudeArgs, '--permission-mode') + 1]
    Assert-Equal 'a live session prints how to open it' '1' "$(@(Get-Content live.err | Where-Object { $_ -like '*claude attach 5dbbc910*' }).Count)"
    Assert-Equal 'a live session keeps its last main-thread answer' 'Table|VERIFY: PASS' ((Get-Content $liveOut) -join '|')
    Assert-Equal 'a live session prints its answer' 'Table|VERIFY: PASS' ($liveShown -join '|')
    Assert-Equal 'a live session records its steps' '1' "$(@(Get-Content (Join-Path $sandbox '.agent/runs/F05/progress.log') | Where-Object { $_ -eq 'F05 · review › Bash git diff main' }).Count)"
    Remove-Item $claudeHome -Recurse -Force

    $watchOutput = pwsh -NoProfile -File "$scriptsDir/watch.ps1" -Once 2>&1
    Assert-Equal 'watch shows the story result' '1' "$(@($watchOutput | Where-Object { $_ -like 'F05  shipped https://example/pull/1*' }).Count)"
    Assert-Equal 'watch shows the last steps' '1' "$(@($watchOutput | Where-Object { $_ -like '*F05 · review › Bash make test-story*' }).Count)"
    Assert-Equal 'watch filters by story id' 'No story has started yet. run.ps1 writes to .agent/runs/<id>.' ((pwsh -NoProfile -File "$scriptsDir/watch.ps1" -Once -Story F99 2>&1) -join '|')

    New-Item -ItemType Directory -Force "$tddRepo/src" | Out-Null
    git -C $tddRepo init -q -b main
    New-Commit $tddRepo base
    git -C $tddRepo switch -q -c feat/x
    $script:BaseBranch = 'main'
    Assert-Equal 'the gate names the missing commit' 'TDD rule: there is no commit.' ((Test-TddCommitOrder F05 $tddRepo) -creplace ' Commit.*$', '')
    New-Item -ItemType File "$tddRepo/src/x_test.go" | Out-Null
    New-Commit $tddRepo 'test(red): proves x'
    New-Item -ItemType File "$tddRepo/src/x.go" | Out-Null
    New-Commit $tddRepo 'feat(F01): x'
    $first = @(git -C $tddRepo log --reverse --format=%H main..HEAD)[0]
    Assert-Equal 'a first commit named test(red) is accepted' 'True' (Test-FirstCommitIsRed $tddRepo $first)
    Assert-Equal 'a feat commit is refused as the first' 'False' (Test-FirstCommitIsRed $tddRepo ((git -C $tddRepo rev-parse HEAD) -join ''))
} finally {
    Set-Location $scriptsDir
    Remove-Item $sandbox, $tddRepo -Recurse -Force -ErrorAction SilentlyContinue
}

if ($script:failures -gt 0) {
    Write-Host "$($script:failures) run.ps1 test(s) failed."
    exit 1
}
Write-Host 'run.ps1 tests passed.'
