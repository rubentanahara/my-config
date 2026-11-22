param(
    [Parameter(Position = 0)][string]$Command = '',
    [Parameter(ValueFromRemainingArguments)][string[]]$Rest = @(),
    [Parameter(ValueFromPipeline)]$Piped
)

begin { $pipedLines = New-Object System.Collections.Generic.List[string] }
process { if ($null -ne $Piped) { $pipedLines.Add([string]$Piped) } }
end {
    . "$PSScriptRoot/common.ps1"

    $featuresFile = 'feature_list.json'
    $progressFile = 'PROGRESS.md'
    $harnessFiles = '["PROGRESS.md","feature_list.json"]'
    $scheduledStates = '["not_started","active"]'
    $unfinishedStates = '["not_started","active","blocked"]'
    $usage = @'
Usage:
  scripts/agent/feature.ps1 add < fragment.json      add epics, stories and sprints (see the backlog skill)
  scripts/agent/feature.ps1 show <id>                print one story with its epic and sprint
  scripts/agent/feature.ps1 status                   progress per sprint and every story not passing
  scripts/agent/feature.ps1 waves                    open stories grouped into waves that can run in parallel
  scripts/agent/feature.ps1 start <id>
  scripts/agent/feature.ps1 done <id>
  scripts/agent/feature.ps1 block <id> "<reason>"
  scripts/agent/feature.ps1 unblock <id>             make a blocked story startable again
  scripts/agent/feature.ps1 scope <id>               files changed on this branch that the story does not own
  scripts/agent/feature.ps1 validate                 fail when feature_list.json was edited by hand
  scripts/agent/feature.ps1 reset                    remove every sprint, epic and story; keep project_title, priority_legend and shared
'@

    $jqDirectory = Join-Path $PSScriptRoot 'jq'
    $storiesJq = (Get-Content (Join-Path $jqDirectory 'stories.jq') -Raw).TrimEnd()
    $wavesJq = $storiesJq + (Get-Content (Join-Path $jqDirectory 'waves.jq') -Raw)
    $addJq = Get-Content (Join-Path $jqDirectory 'add.jq') -Raw
    $makeScript = Join-Path (git rev-parse --show-toplevel) 'make.ps1'

    function Get-StoryField([string]$Id, [string]$Field) {
        (jq -r --arg id $Id ($storiesJq + ' stories[] | select(.id == $id) | .' + $Field + ' // empty') $featuresFile) -join "`n"
    }

    function Assert-State([string]$Id, [string]$Allowed) {
        $state = Get-StoryField $Id 'state'
        if (-not $state) { Stop-Harness "No story $Id in $featuresFile." }
        if (" $Allowed " -notlike "* $state *") { Stop-Harness "$Id is $state. This action needs: $Allowed." }
    }

    function Write-Features([string]$Filter, [string[]]$JqArguments = @()) {
        $output = jq @JqArguments $Filter $featuresFile
        if ($LASTEXITCODE -ne 0) { exit 1 }
        Write-TextFile $featuresFile (($output -join "`n") + "`n")
    }

    function Set-State([string]$Id, [string]$State, [string]$Evidence) {
        Write-Features '.epics |= map(.stories |= map(if .id == $id then .state = $state | .evidence = $evidence else . end))' @('--arg', 'id', $Id, '--arg', 'state', $State, '--arg', 'evidence', $Evidence)
        Write-Host "$Id is now $State."
    }

    function Add-FromFragment {
        $fragment = $pipedLines -join "`n"
        $candidate = jq --argjson fragment $fragment ($storiesJq + $addJq) $featuresFile
        if ($LASTEXITCODE -ne 0) { Stop-Harness 'Nothing added.' }
        $candidate | jq --argjson open_states $unfinishedStates $wavesJq *> $null
        if ($LASTEXITCODE -ne 0) { Stop-Harness 'Nothing added.' }
        Write-TextFile $featuresFile (($candidate -join "`n") + "`n")
        $fragment | jq -r '[.epics[]?.stories[]?.id] as $stories | [.sprints[]?.sprint] as $sprints | "Added \($stories | length) story(ies) as not_started\(if ($stories | length) > 0 then ": " + ($stories | join(", ")) else "" end), and \($sprints | length) sprint(s)."'
    }

    function Show-Story([string]$Id) {
        $story = jq --arg id $Id ($storiesJq + ' stories[] | select(.id == $id)') $featuresFile
        if (-not $story) { Stop-Harness "No story $Id in $featuresFile." }
        $story
    }

    function Show-Status {
        jq -r ($storiesJq + @'

    stories as $all
    | ($all | map(select(.state == "passing") | .id)) as $passing
    | ((.sprints // []) | map({key: (.sprint | tostring), value: .goal}) | from_entries) as $goals
    | $all | group_by(.sprint == null) | map(group_by(.sprint)[]) | .[]
    | (.[0].sprint | tostring) as $sprint
    | "sprint \(if $sprint == "null" then "parked" else $sprint end)\(if $goals[$sprint] then " (\($goals[$sprint]))" else "" end): \(map(select(.state == "passing")) | length)/\(length) passing",
      (.[] | select(.state != "passing")
        | "  \(.id) [\(.state)] \(.name)\(if (.depends_on - $passing | length) > 0 then " (waits on \(.depends_on - $passing | join(", ")))" else "" end)")
'@) $featuresFile
    }

    function Show-Waves {
        $result = jq -c --argjson open_states $scheduledStates $wavesJq $featuresFile
        if ($LASTEXITCODE -ne 0) { exit 1 }
        $result | jq -r '.skipped[]' | ForEach-Object { [Console]::Error.WriteLine($_) }
        $result | jq -r '.waves[] | join(" ")'
    }

    function Start-Story([string]$Id) {
        Assert-State $Id 'not_started blocked'
        $active = (jq -r ($storiesJq + ' [stories[] | select(.state == "active") | .id] | join(", ")') $featuresFile) -join ''
        if ($active) { Stop-Harness "One story at a time: $active is active. Finish it with done or park it with block first." }
        $unmet = (jq -r --arg id $Id ($storiesJq + ' stories as $all | ($all[] | select(.id == $id) | .depends_on) - [$all[] | select(.state == "passing") | .id] | join(", ")') $featuresFile) -join ''
        if ($unmet) { Stop-Harness "$Id depends on $unmet, which is not passing yet." }
        Set-State $Id 'active' ''
    }

    function Get-BaseRevision {
        $defaultBranch = git symbolic-ref -q --short refs/remotes/origin/HEAD 2> $null
        if ($LASTEXITCODE -ne 0) { $defaultBranch = 'main' }
        $base = git merge-base HEAD $defaultBranch 2> $null
        if ($LASTEXITCODE -ne 0) { $base = git rev-parse HEAD }
        "$base".Trim()
    }

    function Get-ChangedFilesJson {
        $files = @(git diff --name-only (Get-BaseRevision)) + @(git ls-files --others --exclude-standard) | Where-Object { $_ } | Sort-Object -Unique
        ConvertTo-Json -InputObject @($files) -Compress
    }

    function Get-FilesOutsideOwns([string]$Id) {
        jq -r --arg id $Id --argjson changed (Get-ChangedFilesJson) --argjson harness $harnessFiles ($storiesJq + @'

    ((.shared // []) + $harness) as $always_allowed
    | (stories[] | select(.id == $id) | .owns // []) as $owns
    | if ($owns | length) == 0 then empty
      else $changed[] | . as $file | select(any(($owns + $always_allowed)[]; covers($file)) | not) end
'@) $featuresFile
    }

    function Test-Scope([string]$Id) {
        if (-not (Get-StoryField $Id 'state')) { Stop-Harness "No story $Id in $featuresFile." }
        $ownsCount = (jq -r --arg id $Id ($storiesJq + ' stories[] | select(.id == $id) | .owns // [] | length') $featuresFile) -join ''
        if ($ownsCount -eq '0') { Write-Host "$Id has no owns, so its scope is not checked."; return }
        $outside = @(Get-FilesOutsideOwns $Id)
        if ($outside.Count -gt 0) {
            [Console]::Error.WriteLine("$Id changed files outside its owns:")
            $outside | ForEach-Object { [Console]::Error.WriteLine("  $_") }
            Stop-Harness "Undo those changes, or block $Id and say which file it needs, so a person can widen its owns."
        }
        Write-Host "$Id changed only files it owns."
    }

    function Complete-Story([string]$Id) {
        Assert-State $Id 'active'
        $mentioned = (Test-Path $progressFile) -and (Select-String -Path $progressFile -Pattern "(?<![A-Za-z0-9_])$([regex]::Escape($Id))(?![A-Za-z0-9_])" -Quiet)
        if (-not $mentioned) { Stop-Harness "$progressFile does not mention $Id, so it stays active. Add what $Id changed, why, and what comes next, then run done again." }
        Test-Scope $Id 6> $null
        & $makeScript check
        if ($LASTEXITCODE -ne 0) { Stop-Harness "make check failed, so $Id stays active. Fix the failures above, then run done again." }
        $testFilter = Get-StoryField $Id 'test_filter'
        $output = & $makeScript test-story -Filter $testFilter 2>&1
        if ($LASTEXITCODE -ne 0) {
            @($output) | Select-Object -Last 30 | ForEach-Object { [Console]::Error.WriteLine($_) }
            Stop-Harness "Tests for $Id failed, so it stays active."
        }
        $revision = git rev-parse --short HEAD 2> $null
        if ($LASTEXITCODE -ne 0) { $revision = 'no commit' }
        if (git status --porcelain) { $revision = "$revision plus uncommitted changes" }
        Set-State $Id 'passing' "tests passed on $revision, $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mmZ'))"
    }

    function Lock-Story([string]$Id, [string]$Reason) {
        Assert-State $Id 'not_started active'
        Set-State $Id 'blocked' $Reason
    }

    function Unlock-Story([string]$Id) {
        Assert-State $Id 'blocked'
        Set-State $Id 'not_started' ''
    }

    function Test-Features {
        $errors = jq -r ($storiesJq + @'

    stories as $all | ($all | map(.id)) as $ids
    | $all[] | . as $story
    | (if (.state | IN("not_started", "active", "blocked", "passing")) then empty else "\(.id) has unknown state \(.state)." end),
      (if (.state | IN("passing", "blocked")) and ((.evidence // "") == "") then "\(.id) is \(.state) with no evidence. Change state only through feature.sh." else empty end),
      ((.depends_on // [])[] | select(. as $dep | $ids | index($dep) | not) | "\($story.id) depends on \(.), which does not exist.")
'@) $featuresFile
        if ($errors) { Stop-Harness ($errors -join "`n") }
        Write-Host 'Backlog is consistent.'
    }

    function Reset-Backlog {
        $active = (jq -r ($storiesJq + ' [stories[] | select(.state == "active") | .id] | join(", ")') $featuresFile) -join ''
        if ($active) { Stop-Harness "$active is active. Finish it with done or park it with block before the reset." }
        Write-Features '.sprints = [] | .epics = []'
        Write-Host 'Backlog reset: no sprints, epics or stories left. project_title, priority_legend and shared are kept.'
    }

    Enter-RepoRoot
    if (-not (Get-Command jq -ErrorAction SilentlyContinue)) { Stop-Harness 'jq is required. Install it (winget install jqlang.jq, or brew install jq) and retry.' }

    $argumentCount = 1 + $Rest.Count
    switch ("$Command $argumentCount") {
        'add 1' { Add-FromFragment }
        'show 2' { Show-Story $Rest[0] }
        'status 1' { Show-Status }
        'waves 1' { Show-Waves }
        'start 2' { Start-Story $Rest[0] }
        'done 2' { Complete-Story $Rest[0] }
        'block 3' { Lock-Story $Rest[0] $Rest[1] }
        'unblock 2' { Unlock-Story $Rest[0] }
        'scope 2' { Test-Scope $Rest[0] }
        'validate 1' { Test-Features }
        'reset 1' { Reset-Backlog }
        default { Stop-Harness $usage }
    }
}
