param(
    [ValidateSet('claude', 'codex', 'copilot', 'agy')][string]$Cli = 'copilot',
    [ValidateSet('', 'claude', 'codex', 'copilot', 'agy')][string]$Checker = '',
    [string]$Model = '',
    [string]$CheckerModel = '',
    [ValidateRange(1, 64)][int]$Parallel = 1,
    [switch]$NoMerge,
    [string]$Story = '',
    [switch]$DryRun,
    [switch]$Help
)

. "$PSScriptRoot/common.ps1"

$usage = @'
Usage: scripts/agent/run.ps1 [-Cli claude|codex|copilot|agy] [-Checker <cli>] [-Model <m>] [-CheckerModel <m>] [-Parallel N] [-NoMerge] [-Story <id>] [-DryRun]

Runs the first wave of scripts/agent/feature.ps1 waves. Each story gets its own worktree and branch and goes through:
implement (a session named "<id> · <name>"), ./make.ps1 check, scope and test gate, an independent read-only review
(the verify skill, in a fresh session), feature.ps1 done, then a commit, a push and a pull request.

  -Cli           CLI that implements. Default: copilot.
  -Checker       CLI that reviews. Default: the same as -Cli.
  -Model         model of the implementer. Default: claude-sonnet-5.5 (copilot), claude-sonnet-5-5 (claude), gpt-5.6-terra (codex)
                 or gemini-3.8-flash-high (agy).
  -CheckerModel  model of the reviewer. Default: claude-opus-5.5 (copilot), otherwise the default of the checker CLI.
  -Parallel      how many stories of a wave run at once, one background job each. Default: 1.
  -NoMerge       stop at open pull requests. Default: merge each pull request once CI is green, then run the next wave.
  -Story         run only this story.
  -DryRun        print what would run, and start nothing.
'@

$maxAttempts = 3
$defaultModels = @{ claude = 'claude-sonnet-5-5'; copilot = 'claude-sonnet-5.5'; codex = 'gpt-5.6-terra'; agy = 'gemini-3.8-flash-high' }
$copilotDefaultCheckerModel = 'claude-opus-5.5'
$worktreesDir = '.worktrees'
$runsDir = '.agent/runs'
$runnerDir = '.agent/runner'
$featureScript = 'scripts/agent/feature.ps1'
$redPrefix = 'test(red)'
$pollSeconds = 15
$checksAppearRounds = 20
$feedbackLines = 60
$slugMaxLength = 40

function Main {
    if ($Help) { Write-Host $usage; exit 0 }
    Resolve-Arguments
    $script:Root = (git rev-parse --show-toplevel) -join ''
    if ($LASTEXITCODE -ne 0) { Stop-Harness 'Run this inside a git repository.' }
    Set-Location $script:Root
    $script:BaseBranch = (git branch --show-current) -join ''
    if (-not $script:BaseBranch) { Stop-Harness 'Check out a branch first, normally main: stories branch from it and their pull requests target it.' }
    if (git status --porcelain) { Stop-Harness 'The working tree is not clean. Commit or stash first: stories branch from HEAD.' }
    if (-not $NoMerge -and $script:BaseBranch -ne (Get-DefaultBranch)) {
        Stop-Harness "Merging needs the default branch ($(Get-DefaultBranch)) checked out, because it pulls each merge before the next wave. Use -NoMerge to run from another branch."
    }
    New-Item -ItemType Directory -Force $runsDir | Out-Null
    if ($Story -and -not $DryRun) {
        Invoke-Story $Story
        exit $LASTEXITCODE
    }
    Invoke-Waves
}

function Resolve-Arguments {
    if (-not $script:Checker) { $script:Checker = $Cli }
    if (-not $script:Model) { $script:Model = $defaultModels[$Cli] }
    if (-not $script:CheckerModel) {
        $script:CheckerModel = if ($script:Checker -eq 'copilot') { $copilotDefaultCheckerModel } else { $defaultModels[$script:Checker] }
    }
    foreach ($name in $Cli, $script:Checker) {
        if (-not (Get-Command $name -ErrorAction SilentlyContinue)) { Stop-Harness "$name is not installed." }
    }
}

function Invoke-Waves {
    while ($true) {
        if (-not $NoMerge) {
            git pull -q --ff-only
            if ($LASTEXITCODE -ne 0) { Stop-Harness "git pull failed on $script:BaseBranch." }
        }
        $ids = @(Get-ReadyStories)
        if ($ids.Count -eq 0) {
            Write-Report "Nothing left to start in the first wave. $(Get-WaitingSummary)"
            return
        }
        if ($DryRun) { Show-Plan $ids; return }
        Invoke-Wave $ids
        Show-Results $ids
        if ($NoMerge) {
            Write-Report 'Stopped at open pull requests. Merge them, then run again for the next wave.'
            return
        }
        if (-not (Merge-Wave $ids)) { exit 1 }
    }
}

function Get-ReadyStories {
    $firstWave = if ($Story) { @($Story) } else { @((Invoke-Feature $script:Root waves 2> $null | Select-Object -First 1) -split ' ' | Where-Object { $_ }) }
    foreach ($id in $firstWave) {
        $pullRequest = Get-OpenPullRequest $id
        if ($pullRequest) {
            [Console]::Error.WriteLine("skip ${id}: in review at $pullRequest")
        } elseif ((Get-WorktreeState $id) -eq 'blocked') {
            [Console]::Error.WriteLine("skip ${id}: blocked in $worktreesDir/$id. Unblock it with feature.ps1 start there, or remove the worktree.")
        } else {
            $id
        }
    }
}

function Get-WaitingSummary {
    $open = gh pr list --state open --base $script:BaseBranch --json number,title,headRefName `
        --jq '.[] | select(.headRefName | startswith("feat/")) | "#\(.number) \(.title)"' 2> $null
    if ($open) { return "Waiting for: $(@($open) -join '; ')" }
    @(Invoke-Feature $script:Root status 2> $null)[0]
}

function Show-Plan([string[]]$Ids) {
    Write-Host "Base: $script:BaseBranch ($((git rev-parse --short HEAD) -join '')). Implementer: $Cli ($script:Model). Reviewer: $script:Checker ($script:CheckerModel), fresh read-only session. Parallel: $Parallel. Merge: $(-not $NoMerge)."
    Write-Host 'Wave:'
    foreach ($id in $Ids) {
        Write-Host "  $(Get-SessionName $id)  branch $(Get-BranchName $id)  worktree $worktreesDir/$id  tests $(Get-StoryField $id test_filter)"
    }
    if ($NoMerge) { Write-Host 'Then: stop at the open pull requests.' } else { Write-Host 'Then: merge each pull request once CI is green, and run the next wave.' }
}

function Invoke-Wave([string[]]$Ids) {
    if ($Parallel -eq 1 -or $Ids.Count -eq 1) {
        foreach ($id in $Ids) { Invoke-Story $id }
        return
    }
    for ($start = 0; $start -lt $Ids.Count; $start += $Parallel) {
        Invoke-InJobs $Ids[$start..([Math]::Min($start + $Parallel, $Ids.Count) - 1)]
    }
}

function Invoke-InJobs([string[]]$Ids) {
    $jobs = foreach ($id in $Ids) {
        New-Item -ItemType Directory -Force (Get-StoryLogDir $id) | Out-Null
        Remove-Item (Get-ResultFile $id) -Force -ErrorAction SilentlyContinue
        $arguments = @('-NoProfile', '-File', $PSCommandPath, '-Story', $id, '-Cli', $Cli, '-Checker', $script:Checker, '-Model', $script:Model, '-CheckerModel', $script:CheckerModel)
        $log = Join-Path (Get-StoryLogDir $id) 'runner.log'
        Start-Job -Name $id -ArgumentList $script:Root, $log, $arguments -ScriptBlock {
            param($root, $log, $arguments)
            Set-Location $root
            & pwsh @arguments *> $log
        }
    }
    Write-Report "Running $($Ids -join ', ') as background jobs. Follow one with: Get-Content -Wait $runsDir/<id>/runner.log"
    $jobs | Wait-Job | Remove-Job
}

function Invoke-Story([string]$Id) {
    $dir = Join-Path $script:Root "$worktreesDir/$Id"
    if (-not (Get-StoryField $Id name)) { Stop-Harness "No story $Id in feature_list.json." }
    New-Item -ItemType Directory -Force (Get-StoryLogDir $Id) | Out-Null
    Remove-Item (Get-ResultFile $Id) -Force -ErrorAction SilentlyContinue
    if (-not (Request-Story $Id $dir)) { Save-Result $Id failed 'could not create its worktree or start it'; $global:LASTEXITCODE = 1; return }
    $feedback = ''
    $passed = $false
    $attempt = 0
    if ((Get-WorktreeState $Id) -eq 'passing') {
        $attempt = @(Get-ChildItem (Get-StoryLogDir $Id) -Filter 'implement-*.log' -ErrorAction SilentlyContinue).Count
        Write-Report "${Id}: already passing in its worktree after $attempt attempt(s); shipping it"
        $passed = $true
    }
    while (-not $passed -and $attempt -lt $maxAttempts) {
        $attempt++
        Write-Report "${Id}: implement, attempt $attempt of $maxAttempts ($Cli, session `"$(Get-SessionName $Id)`")"
        Invoke-Implement $Id $dir $attempt $feedback
        if ((Get-WorktreeState $Id) -eq 'blocked') {
            Save-Result $Id blocked ((Invoke-Feature $dir show $Id | ConvertFrom-Json).evidence)
            $global:LASTEXITCODE = 0
            return
        }
        $feedback = Test-StoryGate $Id $dir $attempt
        if ($feedback) { Write-Report "${Id}: gate failed: $(($feedback -split "`n")[0])"; continue }
        Write-Report "${Id}: review ($script:Checker, fresh read-only session)"
        $feedback = Invoke-Review $Id $dir $attempt
        if ($feedback) { Write-Report "${Id}: review failed: $(($feedback -split "`n")[-1])"; continue }
        $doneOutput = (Invoke-Feature $dir done $Id *>&1 | ForEach-Object { "$_" }) -join "`n"
        if ($LASTEXITCODE -ne 0) {
            $feedback = "feature.ps1 done $Id refused:`n$(Get-LastLines $doneOutput)"
            continue
        }
        $passed = $true
    }
    if (-not $passed) {
        $finding = ($feedback.Substring(0, [Math]::Min(300, $feedback.Length))) -replace "`n", ' '
        Invoke-Feature $dir block $Id "The runner gave up after $maxAttempts attempts. Last finding: $finding" | Out-Null
        Save-Result $Id blocked "gave up after $maxAttempts attempts; see $(Get-StoryLogDir $Id)"
        $global:LASTEXITCODE = 0
        return
    }
    $script:CheckLog = Get-ChildItem (Get-StoryLogDir $Id) -Filter 'check-*.log' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not (Publish-Story $Id $dir $attempt)) {
        Save-Result $Id failed "could not commit, push or open the pull request; the worktree $dir is kept"
        $global:LASTEXITCODE = 1
        return
    }
    $global:LASTEXITCODE = 0
}

function Request-Story([string]$Id, [string]$Dir) {
    $branch = Get-BranchName $Id
    if (Test-Path $Dir) {
        Write-Report "${Id}: reusing worktree $worktreesDir/$Id"
    } else {
        git show-ref -q --verify "refs/heads/$branch"
        if ($LASTEXITCODE -eq 0) { git worktree add -q $Dir $branch } else { git worktree add -q -b $branch $Dir HEAD }
        if ($LASTEXITCODE -ne 0) { return $false }
    }
    if (-not (Install-Dependencies $Dir (Join-Path (Get-StoryLogDir $Id) 'setup.log'))) {
        Write-Report "${Id}: ./make.ps1 setup failed in its worktree; see $(Get-StoryLogDir $Id)/setup.log"
        return $false
    }
    $state = Get-WorktreeState $Id
    switch ($state) {
        { $_ -in 'not_started', 'blocked' } { Invoke-Feature $Dir start $Id | Out-Null; return $LASTEXITCODE -eq 0 }
        { $_ -in 'active', 'passing' } { return $true }
        default { Write-Report "$Id is $state in its worktree."; return $false }
    }
}

function Invoke-Implement([string]$Id, [string]$Dir, [int]$Attempt, [string]$Feedback) {
    $filter = Get-StoryField $Id test_filter
    $prompt = @"
Session "$(Get-SessionName $Id)". You are running unattended in a worktree on branch $(Get-BranchName $Id). Story $Id is already active: scripts/agent/feature.ps1 start ran.
1. Read the story with scripts/agent/feature.ps1 show $Id. If it has a prd field, read only that section of the PRD.
2. Build it with the tdd skill, one acceptance criterion at a time, following ARCHITECTURE.md. Change only files in its owns and the shared files. The runner checks the commit order: ./make.ps1 format, then make your FIRST commit the story's tests, plus only the stubs they need to compile, named ${redPrefix}: <what it proves>. The story's tests (./make.ps1 test-story -Filter "$filter") must fail on it. Then commit the code as feat(${Id}): <what it does>.
3. Run ./make.ps1 format, then ./make.ps1 check until it prints CHECK PASSED.
4. Mention $Id in PROGRESS.md: what changed, why, and what comes next.
The runner does the rest: the independent review, feature.ps1 done, the commit, the push and the pull request. Do not run feature.ps1 done and do not push. Commit only as step 2 says.
You may hand exploration or test drafting to subagents. If something outside the repo stops you, run scripts/agent/feature.ps1 block $Id "<reason>" and stop.
"@
    if ($Feedback) {
        $prompt += "`n`nThis is attempt $Attempt of $maxAttempts. The previous attempt did not pass. Fix these findings first:`n$Feedback"
    }
    Invoke-Session $Dir $Cli $script:Model write (Get-SessionName $Id) $prompt (Join-Path (Get-StoryLogDir $Id) "implement-$Attempt.log")
}

function Test-StoryGate([string]$Id, [string]$Dir, [int]$Attempt) {
    $logDir = Get-StoryLogDir $Id
    New-Item -ItemType Directory -Force (Join-Path $Dir $runnerDir) | Out-Null
    $checkLog = Join-Path $logDir "check-$Attempt.log"
    Invoke-Make $Dir check *> $checkLog
    if ($LASTEXITCODE -ne 0) {
        return "./make.ps1 check failed. Its last lines:`n$(Get-LastLines ((Get-Content $checkLog) -join "`n"))"
    }
    $scope = (Invoke-Feature $Dir scope $Id *>&1 | ForEach-Object { "$_" }) -join "`n"
    if ($LASTEXITCODE -ne 0) { return $scope }
    if (-not (Select-String -Path (Join-Path $Dir 'PROGRESS.md') -Pattern "\b$([regex]::Escape($Id))\b" -Quiet)) {
        return "PROGRESS.md does not mention $Id. Add what $Id changed, why, and what comes next."
    }
    $order = Test-TddCommitOrder $Id $Dir
    if ($order) { return $order }
    $testsLog = Join-Path $Dir "$runnerDir/tests.log"
    Invoke-Make $Dir test-story -Filter (Get-StoryField $Id test_filter) *> $testsLog
    if ($LASTEXITCODE -ne 0) {
        return "The story's tests failed:`n$(Get-LastLines ((Get-Content $testsLog) -join "`n"))"
    }
    ''
}

function Test-TddCommitOrder([string]$Id, [string]$Dir) {
    $base = (git -C $Dir merge-base HEAD $script:BaseBranch) -join ''
    $first = @(git -C $Dir log --reverse --format=%H "$base..HEAD")[0]
    if (-not $first) {
        return "TDD rule: there is no commit. Commit the story's failing tests first as ${redPrefix}: <what>, then commit the code."
    }
    if (-not (Test-FirstCommitIsRed $Dir $first)) {
        return "TDD rule: the first commit must hold the story's failing tests and be named ${redPrefix}: <what>. Undo the history with git reset --soft $base, commit the tests and only the stubs they need as ${redPrefix}: ..., run ./make.ps1 format, and commit the code after it."
    }
    Test-FirstCommitFailsTests $Id $Dir $first
}

function Test-FirstCommitIsRed([string]$Dir, [string]$Sha) {
    ((git -C $Dir log -1 --format=%s $Sha) -join '').StartsWith($redPrefix)
}

function Test-FirstCommitFailsTests([string]$Id, [string]$Dir, [string]$Sha) {
    $red = Join-Path (Get-StoryLogDir $Id) 'red'
    Remove-Item $red -Recurse -Force -ErrorAction SilentlyContinue
    git -C $Dir worktree add -q --detach $red $Sha
    if ($LASTEXITCODE -ne 0) { return 'Could not check out the first commit to prove its tests fail.' }
    try {
        if (-not (Install-Dependencies $red (Join-Path (Get-StoryLogDir $Id) 'red-setup.log'))) {
            return "./make.ps1 setup failed on the first commit, so the runner could not prove its tests fail. Log: $(Get-StoryLogDir $Id)/red-setup.log"
        }
        Invoke-Make $red test-story -Filter (Get-StoryField $Id test_filter) *> (Join-Path (Get-StoryLogDir $Id) 'red.log')
        if ($LASTEXITCODE -eq 0) {
            return "TDD rule: the story's tests pass on the first commit, so they prove nothing it added. Make the first commit's tests fail, then add the code in a later commit. Log: $(Get-StoryLogDir $Id)/red.log"
        }
        ''
    } finally {
        git -C $Dir worktree remove --force $red
    }
}

function Invoke-Review([string]$Id, [string]$Dir, [int]$Attempt) {
    $out = Join-Path (Get-StoryLogDir $Id) "review-$Attempt.md"
    $base = (git -C $Dir merge-base HEAD $script:BaseBranch) -join ''
    $prompt = @"
Session "$Id · review". You are the independent reviewer of story $Id. You did not write this code. Run the verify skill for $Id.
The change is git diff $base plus the untracked files git status lists.
The runner already ran ./make.ps1 check, which passed, and the story's tests. Their output is in $runnerDir/tests.log: read it instead of building or running the tests.
Do not edit, create or delete any file. End with the VERIFY line.
"@
    $before = Get-WorktreeFingerprint $Dir
    Invoke-Session $Dir $script:Checker $script:CheckerModel read "$Id · review" $prompt $out | Out-Null
    if ((Get-WorktreeFingerprint $Dir) -ne $before) {
        return 'The reviewer changed files, so its review does not count. Undo any change it made.'
    }
    $verdict = Get-Verdict $out
    Copy-Item $out (Join-Path $Dir "$runnerDir/review.md") -Force
    if ($verdict -eq 'VERIFY: PASS') { return '' }
    "The independent review failed ($(if ($verdict) { $verdict } else { 'no VERIFY line' })). Its report:`n$(Get-LastLines ((Get-Content $out) -join "`n"))"
}

function Publish-Story([string]$Id, [string]$Dir, [int]$Attempts) {
    $branch = Get-BranchName $Id
    $name = Get-StoryField $Id name
    $subject = "feat(${Id}): $($name.Substring(0, 1).ToLower())$($name.Substring(1))"
    Push-Location $Dir
    try {
        git add -A
        git diff --cached --quiet
        if ($LASTEXITCODE -ne 0) {
            git commit -q -m $subject -m (Get-StoryField $Id title)
            if ($LASTEXITCODE -ne 0) { return $false }
        }
        git push -q -u origin $branch
        if ($LASTEXITCODE -ne 0) { return $false }
    } finally {
        Pop-Location
    }
    $body = Get-PullRequestBody $Id $Dir $Attempts
    $url = (gh pr create --base $script:BaseBranch --head $branch --title $subject --body $body) -join ''
    if ($LASTEXITCODE -ne 0) { return $false }
    git worktree remove $Dir
    if ($LASTEXITCODE -ne 0) { Write-Report "${Id}: kept the worktree $Dir; remove it with git worktree remove." }
    Save-Result $Id shipped $url
    $true
}

function Get-PullRequestBody([string]$Id, [string]$Dir, [int]$Attempts) {
    $story = Invoke-Feature $script:Root show $Id | ConvertFrom-Json
    $criteria = ($story.acceptance_criteria | ForEach-Object { "- [x] $_" }) -join "`n"
    $review = Get-Content (Join-Path $Dir "$runnerDir/review.md")
    $tableStart = [Array]::FindIndex([string[]]$review, [Predicate[string]] { param($line) $line.StartsWith('|') })
    $reviewTable = if ($tableStart -ge 0) { $review[$tableStart..($review.Count - 1)] -join "`n" } else { '' }
    $checkLine = if ($script:CheckLog) { Select-String -Path $script:CheckLog.FullName -Pattern 'CHECK PASSED' | Select-Object -First 1 | ForEach-Object { $_.Line } }
    if (-not $checkLine) { $checkLine = 'make check passed' }
    $evidence = (Invoke-Feature $Dir show $Id | ConvertFrom-Json).evidence
    @"
## $($story.id) · $($story.name)
$($story.title)

### Acceptance criteria
$criteria

### Independent review ($script:Checker, fresh session)
$reviewTable

### Evidence
- ``$checkLine``
- ``feature.ps1 done``: $evidence
- Implemented by $Cli in session "$(Get-SessionName $Id)", $Attempts attempt(s).
"@
}

function Merge-Wave([string[]]$Ids) {
    foreach ($id in $Ids) {
        $url = Get-Result $id shipped
        if (-not $url) { continue }
        if (-not (Merge-PullRequest $id $url)) { return $false }
    }
    $true
}

function Wait-ForChecks([string]$Url) {
    for ($round = 0; $round -lt $checksAppearRounds; $round++) {
        if ((gh pr view $Url --json statusCheckRollup --jq '.statusCheckRollup | length') -ne '0') { return }
        Start-Sleep -Seconds $pollSeconds
    }
}

function Merge-PullRequest([string]$Id, [string]$Url) {
    Wait-ForChecks $Url
    $state = ''
    foreach ($round in 1..3) {
        gh pr checks $Url --watch --fail-fast --interval $pollSeconds *> $null
        if ($LASTEXITCODE -ne 0) {
            Write-Report "${Id}: CI failed on $Url. Not merged; the run stops here."
            return $false
        }
        $state = (gh pr view $Url --json mergeStateStatus --jq .mergeStateStatus) -join ''
        switch ($state) {
            { $_ -in 'CLEAN', 'HAS_HOOKS', 'UNSTABLE' } {
                $head = (gh pr view $Url --json headRefOid --jq .headRefOid) -join ''
                gh pr merge $Url --squash --delete-branch --match-head-commit $head *> $null
                if ($LASTEXITCODE -ne 0) { return $false }
                git pull -q --ff-only
                Write-Report "${Id}: merged $Url"
                return $true
            }
            'BEHIND' {
                gh pr update-branch $Url *> $null
                if ($LASTEXITCODE -ne 0 -and -not (Resolve-Conflicts $Id)) { return $false }
            }
            'DIRTY' { if (-not (Resolve-Conflicts $Id)) { return $false } }
            default { Start-Sleep -Seconds $pollSeconds }
        }
    }
    Write-Report "${Id}: $Url is still not mergeable ($state). Not merged; the run stops here."
    $false
}

function Resolve-Conflicts([string]$Id) {
    $dir = Join-Path $script:Root "$worktreesDir/$Id"
    $branch = Get-BranchName $Id
    $session = "$Id · merge $script:BaseBranch"
    git fetch -q origin $script:BaseBranch $branch
    if (-not (Test-Path $dir)) {
        git worktree add -q $dir $branch
        if ($LASTEXITCODE -ne 0) { return $false }
    }
    git -C $dir merge -q --ff-only "origin/$branch" 2> $null
    Write-Report "${Id}: resolving conflicts with $script:BaseBranch ($Cli, session `"$session`")"
    $prompt = "Session `"$session`". Run git merge origin/$script:BaseBranch in this worktree and resolve every conflict so both sides keep working. Run ./make.ps1 check until it prints CHECK PASSED, then commit the merge. Do not push."
    Invoke-Session $dir $Cli $script:Model write $session $prompt (Join-Path (Get-StoryLogDir $Id) 'resolve.log') | Out-Null
    git -C $dir merge-base --is-ancestor "origin/$script:BaseBranch" HEAD
    $resolved = $LASTEXITCODE -eq 0
    if ($resolved) { Invoke-Make $dir check *> $null; $resolved = $LASTEXITCODE -eq 0 }
    if ($resolved) { git -C $dir push -q origin $branch; $resolved = $LASTEXITCODE -eq 0 }
    if (-not $resolved) {
        Write-Report "${Id}: conflicts are not resolved; see $(Get-StoryLogDir $Id)/resolve.log and the worktree $dir."
        return $false
    }
    git worktree remove $dir *> $null
    $true
}

function Invoke-Session([string]$Dir, [string]$SessionCli, [string]$SessionModel, [string]$Mode, [string]$Name, [string]$Prompt, [string]$Out) {
    Push-Location $Dir
    try {
        switch ("${SessionCli}:$Mode") {
            'claude:write' { $null | claude -p $Prompt --model $SessionModel -n $Name --permission-mode bypassPermissions --disallowedTools 'Bash(git push *)' 2>&1 | Tee-Object -FilePath $Out }
            'claude:read' {
                $null | claude -p $Prompt --model $SessionModel -n $Name --disallowedTools Edit Write NotebookEdit 'Bash(./make.ps1 format)' `
                    'Bash(scripts/agent/feature.ps1 start *)' 'Bash(scripts/agent/feature.ps1 done *)' 'Bash(scripts/agent/feature.ps1 block *)' `
                    'Bash(scripts/agent/feature.ps1 add *)' 2>&1 | Tee-Object -FilePath $Out
            }
            'codex:write' { $null | codex exec -m $SessionModel --dangerously-bypass-approvals-and-sandbox $Prompt 2>&1 | Tee-Object -FilePath $Out }
            'codex:read' {
                $null | codex exec -m $SessionModel --sandbox read-only -o $Out $Prompt *> "$Out.log"
                Get-Content $Out -Tail 20 -ErrorAction SilentlyContinue
            }
            'copilot:write' { copilot -p $Prompt --model $SessionModel -n $Name --allow-all --no-ask-user --deny-tool 'shell(git push)' 2>&1 | Tee-Object -FilePath $Out }
            'copilot:read' {
                copilot -p $Prompt --model $SessionModel -n $Name -s --no-ask-user --deny-tool write `
                    --allow-tool 'shell(git diff:*)' --allow-tool 'shell(git status:*)' --allow-tool 'shell(git log:*)' --allow-tool 'shell(git show:*)' `
                    --allow-tool 'shell(scripts/agent/feature.ps1 show:*)' --allow-tool 'shell(scripts/agent/feature.ps1 scope:*)' 2>&1 | Tee-Object -FilePath $Out
            }
            'agy:write' { $null | agy -p $Prompt --model $SessionModel --dangerously-skip-permissions 2>&1 | Tee-Object -FilePath $Out }
            'agy:read' { $null | agy -p $Prompt --model $SessionModel --mode auto --sandbox 2>&1 | Tee-Object -FilePath $Out }
        }
    } finally {
        Pop-Location
    }
}

function Invoke-Feature([string]$Dir, [Parameter(ValueFromRemainingArguments)][string[]]$Arguments) {
    Push-Location $Dir
    try { pwsh -NoProfile -File (Join-Path $Dir $featureScript) @Arguments } finally { Pop-Location }
}

function Invoke-Make([string]$Dir, [Parameter(ValueFromRemainingArguments)][string[]]$Arguments) {
    Push-Location $Dir
    try { pwsh -NoProfile -File (Join-Path $Dir 'make.ps1') @Arguments } finally { Pop-Location }
}

function Install-Dependencies([string]$Dir, [string]$Log) {
    Invoke-Make $Dir setup *> $Log
    $LASTEXITCODE -eq 0
}

function Get-WorktreeFingerprint([string]$Dir) {
    Push-Location $Dir
    try { Get-TreeFingerprint } finally { Pop-Location }
}

function Get-Verdict([string]$Path) {
    if (-not (Test-Path $Path)) { return '' }
    $found = [regex]::Matches((Get-Content $Path -Raw), 'VERIFY: (PASS|FAIL[^`*\r\n]*)')
    if ($found.Count -eq 0) { return '' }
    $found[$found.Count - 1].Value.TrimEnd()
}

function Get-OpenPullRequest([string]$Id) {
    (gh pr list --state open --head (Get-BranchName $Id) --json url --jq '.[0].url // empty' 2> $null) -join ''
}

function Get-WorktreeState([string]$Id) {
    $dir = Join-Path $script:Root "$worktreesDir/$Id"
    if (-not (Test-Path $dir)) { return '' }
    $story = Invoke-Feature $dir show $Id 2> $null
    if ($LASTEXITCODE -ne 0) { return '' }
    ($story | ConvertFrom-Json).state
}

function Get-StoryField([string]$Id, [string]$Field) {
    $story = Invoke-Feature $script:Root show $Id 2> $null
    if ($LASTEXITCODE -ne 0 -or -not $story) { return '' }
    $value = ($story | ConvertFrom-Json).$Field
    if ($null -eq $value) { '' } else { "$value" }
}

function Get-SessionName([string]$Id) { "$Id · $(Get-StoryField $Id name)" }

function Get-BranchName([string]$Id) { "feat/$(ConvertTo-Slug "$Id-$(Get-StoryField $Id name)")" }

function ConvertTo-Slug([string]$Text) {
    $slug = ($Text.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
    $slug.Substring(0, [Math]::Min($slugMaxLength, $slug.Length)).TrimEnd('-')
}

function Get-DefaultBranch {
    $ref = (git symbolic-ref -q --short refs/remotes/origin/HEAD 2> $null) -join ''
    if ($ref) { $ref -replace '^origin/', '' } else { 'main' }
}

function Get-LastLines([string]$Text) { (($Text -split "`n") | Select-Object -Last $feedbackLines) -join "`n" }

function Get-StoryLogDir([string]$Id) { Join-Path $script:Root "$runsDir/$Id" }

function Get-ResultFile([string]$Id) { Join-Path (Get-StoryLogDir $Id) 'result' }

function Save-Result([string]$Id, [string]$Outcome, [string]$Detail) {
    New-Item -ItemType Directory -Force (Get-StoryLogDir $Id) | Out-Null
    Set-Content (Get-ResultFile $Id) "$Outcome $Detail"
    Write-Report "${Id}: $Outcome $Detail"
}

function Get-Result([string]$Id, [string]$Outcome) {
    $file = Get-ResultFile $Id
    if (-not (Test-Path $file)) { return '' }
    $line = (Get-Content $file -Raw).TrimEnd()
    if ($line.StartsWith("$Outcome ")) { $line.Substring($Outcome.Length + 1) } else { '' }
}

function Show-Results([string[]]$Ids) {
    Write-Host 'Results:'
    foreach ($id in $Ids) {
        $file = Get-ResultFile $id
        Write-Host "  ${id}: $(if (Test-Path $file) { (Get-Content $file -Raw).TrimEnd() } else { 'no result' })"
    }
}

function Write-Report([string]$Message) { [Console]::Error.WriteLine("run: $Message") }

if ($MyInvocation.InvocationName -ne '.') { Main }
