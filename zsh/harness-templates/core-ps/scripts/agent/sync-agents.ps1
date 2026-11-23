param(
    [string]$SourceDir = '.claude/agents',
    [string]$TargetDir = '.codex/agents'
)

. "$PSScriptRoot/common.ps1"

$tomlLiteralDelimiter = "'''"

function Get-FrontmatterValue([string[]]$Lines, [string]$Key) {
    if ($Lines.Count -eq 0 -or $Lines[0] -ne '---') { return '' }
    for ($index = 1; $index -lt $Lines.Count -and $Lines[$index] -ne '---'; $index++) {
        if ($Lines[$index].StartsWith("${Key}: ")) { return $Lines[$index].Substring($Key.Length + 2) }
    }
    ''
}

function Get-Body([string[]]$Lines) {
    $separators = 0
    $body = foreach ($line in $Lines) {
        if ($separators -ge 2) { $line; continue }
        if ($line -eq '---') { $separators++ }
    }
    @($body) -join "`n"
}

function Write-CodexAgent([System.IO.FileInfo]$Agent) {
    $lines = @(Get-Content $Agent.FullName)
    $name = (Get-FrontmatterValue $lines 'name') -replace '-', '_'
    $description = Get-FrontmatterValue $lines 'description'
    $instructions = Get-Body $lines
    if ($name -notmatch '^[a-z0-9_]+$' -or -not $description) {
        Stop-Harness "$($Agent.FullName) needs a name of lowercase letters, digits and hyphens, and a description."
    }
    if ($instructions.Contains($tomlLiteralDelimiter)) {
        Stop-Harness "$($Agent.FullName) contains $tomlLiteralDelimiter, which the Codex TOML copy cannot hold."
    }
    $quotedDescription = (jq -n --arg text $description '$text') -join ''
    $toml = "name = `"$name`"`ndescription = $quotedDescription`ndeveloper_instructions = $tomlLiteralDelimiter`n$instructions`n$tomlLiteralDelimiter`n"
    [System.IO.File]::WriteAllText([System.IO.Path]::Combine((Resolve-Path $TargetDir).Path, "$name.toml"), $toml, $script:Utf8NoBom)
}

Remove-Item $TargetDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $TargetDir | Out-Null
Get-ChildItem $SourceDir -Filter '*.md' | ForEach-Object { Write-CodexAgent $_ }
