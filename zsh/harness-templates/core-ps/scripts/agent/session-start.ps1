. "$PSScriptRoot/common.ps1"

$progressFile = 'PROGRESS.md'
$featuresFile = 'feature_list.json'
$featureScript = Join-Path $PSScriptRoot 'feature.ps1'
$hookContextMaxChars = 9000
$wavesShown = 5
$logFile = '.agent/session-start.log'
$baselineRetentionDays = 7

function Get-CallingCli {
    $process = (Get-Process -Id $PID).Parent
    while ($process) {
        $name = $process.ProcessName -replace '\.(exe|cmd|ps1)$', ''
        if ($name -in 'claude', 'copilot', 'codex') { return $name }
        $process = $process.Parent
    }
    'unknown'
}

function Get-OpenStoryCount {
    $count = jq '[.epics[].stories[] | select(.state != "passing")] | length' $featuresFile 2> $null
    if ($LASTEXITCODE -eq 0) { [int]$count } else { 0 }
}

function Get-BacklogSummary {
    $lines = @(& $featureScript status *>&1)
    $lines += ''
    $lines += 'Ready now, wave by wave (stories on one line can run in parallel):'
    $waves = @(& $featureScript waves *>&1)
    if ($LASTEXITCODE -ne 0) { return $lines + $waves }
    if ($waves.Count -eq 0) { $waves = @('Nothing. Every scheduled story is passing.') }
    $lines + @($waves | Select-Object -First $wavesShown)
}

function Limit-HookContext([string]$Text) {
    $note = "[Cut to $hookContextMaxChars characters to stay under the 10000 Claude Code keeps in context. Read $progressFile for the rest.]"
    if ($Text.Length -le $hookContextMaxChars) { return $Text }
    $cut = $Text.Substring(0, $hookContextMaxChars - $note.Length - 1)
    $lastBreak = $cut.LastIndexOf("`n")
    if ($lastBreak -ge 0) { $cut = $cut.Substring(0, $lastBreak) }
    "$cut`n$note"
}

function Save-SessionBaseline([string]$BaselineFile) {
    New-Item -ItemType Directory -Force (Split-Path $BaselineFile) | Out-Null
    Get-ChildItem (Split-Path $BaselineFile) -Filter 'session-baseline-*' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$baselineRetentionDays) } | Remove-Item -Force
    $progressHash = if (Test-Path $progressFile) { (git hash-object $progressFile) -join '' } else { '' }
    Set-Content $BaselineFile @((Get-TreeFingerprint), $progressHash)
}

$hookInput = Read-HookInput
$sessionId = Get-SessionId $hookInput
$baselineFile = ".agent/session-baseline$(if ($sessionId) { "-$sessionId" })"

Enter-RepoRoot

$cli = Get-CallingCli
$checkOutput = @(& (Join-Path (Get-Location) 'make.ps1') check *>&1 | ForEach-Object { "$_" })
$checkResult = if ($checkOutput.Count -gt 0) { $checkOutput[-1] } else { '' }

$contextLines = @(
    "Session start. Read this before editing. make check ran just now: $checkResult"
    ''
    '## make check'
) + $checkOutput + @(
    ''
    "## Backlog in $featuresFile (scripts/agent/feature.ps1 show <id> prints one story)"
) + (Get-BacklogSummary) + @(
    ''
    "## $progressFile"
) + $(if (Test-Path $progressFile) { Get-Content $progressFile })
$context = Limit-HookContext ($contextLines -join "`n")

$notice = "session-start hook ran in ${cli}: loaded $progressFile and $(Get-OpenStoryCount) open story(ies). make check: $checkResult"
New-Item -ItemType Directory -Force (Split-Path $logFile) | Out-Null
Save-SessionBaseline $baselineFile
Add-Content $logFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $notice"

$output = [ordered]@{
    systemMessage      = $notice
    hookSpecificOutput = [ordered]@{ hookEventName = 'SessionStart'; additionalContext = $context }
}
if ($cli -ne 'codex') { $output.additionalContext = $context }
$output | ConvertTo-Json -Depth 4 -Compress
