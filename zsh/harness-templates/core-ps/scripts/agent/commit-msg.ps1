param([string]$MessageFile)

$conventionalCommit = '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?: .{1,88}$'
$agentAttribution = '(?i)^(co-authored-by:.*(claude|codex|copilot|anthropic\.com|openai\.com)|.*generated (with|by) \[(claude|codex|copilot))'

$lines = Get-Content $MessageFile
$subject = if ($lines) { @($lines)[0] } else { '' }

if ($subject -notmatch $conventionalCommit) {
    Write-Host 'Commit message must follow Conventional Commits:'
    Write-Host '  <type>(<scope>)?: <description>'
    Write-Host '  types: feat fix docs style refactor perf test build ci chore revert'
    Write-Host ''
    Write-Host "Got: $subject"
    exit 1
}

$body = @()
foreach ($line in $lines) {
    if ($line -match '^# -* >8 -*$') { break }
    if ($line -notmatch '^#') { $body += $line }
}
$attributed = @($body | Where-Object { $_ -match $agentAttribution })
if ($attributed.Count -gt 0) {
    Write-Host 'Commit message must not name an AI agent. Remove:'
    $attributed | ForEach-Object { Write-Host $_ }
    exit 1
}

& "$PSScriptRoot/tdd-gate.ps1" $MessageFile
exit $LASTEXITCODE
