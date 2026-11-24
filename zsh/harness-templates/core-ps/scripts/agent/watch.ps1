param(
    [switch]$Once,
    [ValidateRange(1, 3600)][int]$Interval = 5,
    [string]$Story = '',
    [switch]$Help
)

$usage = @'
Usage: scripts/agent/watch.ps1 [-Once] [-Interval <seconds>] [-Story <id>]

Shows each story run.ps1 started: its result, its implement attempts, the commits and changed files in its worktree,
and the last steps of its sessions. Refreshes until Ctrl+C. Run it in a second terminal next to run.ps1.
Steps are recorded for claude sessions only; other CLIs show commits and files.

  -Once      print once and exit.
  -Interval  seconds between refreshes. Default: 5.
  -Story     show only this story.
'@

$runsDir = '.agent/runs'
$worktreesDir = '.worktrees'
$stepsShown = 5

function Main {
    if ($Help) { Write-Host $usage; return }
    $root = git rev-parse --show-toplevel 2> $null
    if ($LASTEXITCODE -ne 0) { [Console]::Error.WriteLine('Run watch.ps1 inside a git repository.'); exit 1 }
    Set-Location $root
    if ($Once) { Show-Stories; return }
    while ($true) {
        Clear-Host
        Show-Stories
        Start-Sleep -Seconds $Interval
    }
}

function Show-Stories {
    $ids = @(Get-ChildItem $runsDir -Directory -ErrorAction SilentlyContinue | ForEach-Object Name | Where-Object { -not $Story -or $_ -eq $Story })
    if ($ids.Count -eq 0) { Write-Host "No story has started yet. run.ps1 writes to $runsDir/<id>."; return }
    foreach ($id in $ids) { Show-Story $id }
}

function Show-Story([string]$Id) {
    $logDir = Join-Path $runsDir $Id
    $worktree = Join-Path $worktreesDir $Id
    $attempts = @(Get-ChildItem $logDir -Filter 'implement-*.log' -File -ErrorAction SilentlyContinue).Count
    Write-Host "$Id  $(Get-StoryResult $Id)  attempts: $attempts"
    if (Test-Path $worktree) {
        Write-Host '  commits:'
        git -C $worktree log --oneline "$(Get-StoryBase $worktree)..HEAD" 2> $null | ForEach-Object { Write-Host "    $_" }
        Write-Host "  changed files: $(@(git -C $worktree status --porcelain).Count)"
    }
    $progress = Join-Path $logDir 'progress.log'
    if ((Test-Path $progress) -and (Get-Item $progress).Length -gt 0) {
        Write-Host '  last steps:'
        Get-Content $progress -Tail $stepsShown | ForEach-Object { Write-Host "    $_" }
    }
    Write-Host ''
}

function Get-StoryResult([string]$Id) {
    $file = Join-Path $runsDir "$Id/result"
    if (Test-Path $file) { return (Get-Content $file -Raw).TrimEnd() }
    'in progress'
}

function Get-StoryBase([string]$Worktree) {
    $default = (git -C $Worktree symbolic-ref -q --short refs/remotes/origin/HEAD 2> $null) -join ''
    if (-not $default) { $default = 'main' }
    $base = (git -C $Worktree merge-base HEAD $default 2> $null) -join ''
    if ($base) { $base } else { 'HEAD' }
}

if ($MyInvocation.InvocationName -ne '.') { Main }
