$PSNativeCommandArgumentPassing = 'Standard'
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Stop-Harness([string]$Message, [int]$Code = 1) {
    [Console]::Error.WriteLine($Message)
    exit $Code
}

function Enter-RepoRoot {
    $root = git rev-parse --show-toplevel 2> $null
    if ($LASTEXITCODE -ne 0) { exit 0 }
    Set-Location $root
}

function Write-TextFile([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText((Join-Path (Get-Location) $Path), $Text, $script:Utf8NoBom)
}

function Read-HookInput {
    if (-not [Console]::IsInputRedirected) { return '' }
    $read = [Console]::In.ReadToEndAsync()
    if ($read.Wait(2000)) { $read.Result } else { '' }
}

function Get-SessionId([string]$HookInput) {
    if ($HookInput -match '"(?:session_?[iI]d|conversationId)"\s*:\s*"([^"]+)"') { return ($Matches[1] -replace '[^A-Za-z0-9_-]', '') }
    ''
}

function Get-TreeFingerprint {
    $diffFile = [System.IO.Path]::GetTempFileName()
    try {
        $head = (git rev-parse HEAD 2> $null) -join ''
        git diff HEAD --binary --output=$diffFile 2> $null
        $diffHash = (git hash-object $diffFile) -join ''
        $untracked = @(git ls-files --others --exclude-standard)
        $links = @($untracked | Where-Object { (Get-Item -LiteralPath $_ -Force).LinkType })
        $files = @($untracked | Where-Object { $_ -notin $links })
        $linkTargets = ($links | ForEach-Object { "$_ -> $((Get-Item -LiteralPath $_ -Force).Target)" }) -join "`n"
        $untrackedHashes = if ($files.Count -gt 0) { ($files | git hash-object --stdin-paths) -join "`n" } else { '' }
        ("$head`n$diffHash`n$linkTargets`n$untrackedHashes" | git hash-object --stdin) -join ''
    } finally {
        Remove-Item $diffFile -Force -ErrorAction SilentlyContinue
    }
}
