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
