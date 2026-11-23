param([string]$HookCli = '')
. "$PSScriptRoot/common.ps1"

$maxAttempts = 3
$failureLines = 40
$logs = '.agent'
$progressFile = 'PROGRESS.md'

function Block-Stop([string]$Reason) {
    $decision = if ($HookCli -eq 'agy') { 'continue' } else { 'block' }
    @{ decision = $decision; reason = $Reason } | ConvertTo-Json -Compress
    exit 0
}

function Read-Counter([string]$Path) { if (Test-Path $Path) { [int](Get-Content $Path -Raw) } else { 0 } }

function Step-Attempt([string]$Path) {
    $attempts = (Read-Counter $Path) + 1
    Set-Content $Path $attempts
    $attempts
}

function Test-Recorded([string]$Path, [string]$Value) {
    (Test-Path $Path) -and ((Get-Content $Path -Raw).Trim() -eq $Value)
}

function Get-FailureExcerpt {
    $lines = Get-Content "$logs/check.log" | Where-Object { $_ -notmatch '^make: \*\*\*' } | Select-Object -Last $failureLines
    (($lines -join "`n") -replace '[\x00-\x08\x0B\x0C\x0E-\x1F]', '')
}

function Test-SessionChangesMissingFromProgress([string]$Fingerprint) {
    $baselineFingerprint = ''
    $baselineProgress = (git rev-parse -q --verify "HEAD:$progressFile" 2> $null) -join ''
    if (Test-Path $baselineFile) {
        $baseline = @(Get-Content $baselineFile)
        $baselineFingerprint = $baseline[0]
        $baselineProgress = $baseline[1]
    } elseif ($sessionId) {
        return $false
    }
    $currentProgress = if (Test-Path $progressFile) { (git hash-object $progressFile) -join '' } else { '' }
    ($Fingerprint -ne $baselineFingerprint) -and ($currentProgress -eq $baselineProgress)
}

$hookInput = Read-HookInput
$sessionId = Get-SessionId $hookInput
$suffix = if ($sessionId) { "-$sessionId" } else { '' }
$baselineFile = "$logs/session-baseline$suffix"
$attemptsFile = "$logs/stop-gate-attempts$suffix"
$progressGaveUpFile = "$logs/progress-gate-gave-up$suffix"
$progressAttemptsFile = "$logs/progress-gate-attempts$suffix"
$passedFile = "$logs/stop-gate-passed"
$gaveUpFile = "$logs/stop-gate-gave-up"

Enter-RepoRoot
New-Item -ItemType Directory -Force $logs | Out-Null

if (-not (git status --porcelain)) {
    Remove-Item $attemptsFile -Force -ErrorAction SilentlyContinue
    exit 0
}

$fingerprint = Get-TreeFingerprint
if (-not (Test-Recorded $progressGaveUpFile $fingerprint) -and (Test-SessionChangesMissingFromProgress $fingerprint)) {
    $attempts = Step-Attempt $progressAttemptsFile
    if ($attempts -gt $maxAttempts) {
        Remove-Item $progressAttemptsFile -Force -ErrorAction SilentlyContinue
        Set-Content $progressGaveUpFile $fingerprint
        Block-Stop "$progressFile is still unchanged after $maxAttempts attempts. If this session changed files, add what changed, why, and what comes next to $progressFile. If it changed nothing, another session did: say so and stop."
    }
    Block-Stop "Not done: files changed during this session but $progressFile did not (attempt $attempts of $maxAttempts). Add what changed, why, and what comes next to it, then finish."
}
Remove-Item $progressAttemptsFile -Force -ErrorAction SilentlyContinue
if (Test-Recorded $passedFile $fingerprint) { exit 0 }
if (Test-Recorded $gaveUpFile $fingerprint) { exit 0 }

& (Join-Path (Get-Location) 'make.ps1') check *> "$logs/check.log"
if ($LASTEXITCODE -eq 0) {
    Set-Content $passedFile $fingerprint
    Remove-Item $attemptsFile -Force -ErrorAction SilentlyContinue
    exit 0
}

$attempts = Step-Attempt $attemptsFile
if ($attempts -gt $maxAttempts) {
    Remove-Item $attemptsFile -Force -ErrorAction SilentlyContinue
    Set-Content $gaveUpFile $fingerprint
    Block-Stop "make check still fails after $maxAttempts attempts. Stop changing code. Tell the user plainly that the work is not done, quote the failure below, and list what you tried.`n`n$(Get-FailureExcerpt)"
}

Block-Stop "Not done: make check failed (attempt $attempts of $maxAttempts). Fix the cause, run ./make.ps1 check until it prints CHECK PASSED, then finish. Full output: $logs/check.log.`n`n$(Get-FailureExcerpt)"
