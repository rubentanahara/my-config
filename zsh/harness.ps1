$script:HarnessTemplates = Join-Path $PSScriptRoot 'harness-templates'
$script:CheapestModel = @{ claude = 'haiku'; codex = 'gpt-6-luna'; copilot = 'auto'; gemini = 'flash-lite' }
$script:AgentDirectories = '.claude/skills', '.claude/agents', '.claude/hooks', '.claude/commands', '.claude/workflows', '.claude/routines',
    '.github/agents', '.github/prompts', '.github/instructions', '.github/workflows', '.github/hooks'
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Find-Executable([string]$Name) {
    Get-Command $Name -CommandType Application, ExternalScript -ErrorAction SilentlyContinue | Select-Object -First 1
}

$script:BashOnlyFiles = 'Makefile', 'scripts/agent/*.sh', '.husky/*', '.claude/settings.json', '.codex/hooks.json', '.github/workflows/check.yml'

function Convert-ToPowerShellText([string]$Text) {
    $Text = $Text -replace '\b(feature|session-start|stop-gate|tdd-gate|tree-fingerprint|protect-main)\.sh\b', '$1.ps1'
    $Text = $Text -replace '\bmake (check|setup|format|run|clean|build|lint|test-story|test)\b', './make.ps1 $1'
    $Text = $Text -replace 'FILTER=', '-Filter '
    $Text -replace '\bMakefile\b', 'commands.mk'
}

function Copy-TreeWithoutOverwrite([string]$Source, [string]$Destination, [string[]]$Exclude = @(), [switch]$ConvertDocs) {
    $root = (Resolve-Path $Source).Path
    Get-ChildItem $root -Recurse -Force -File | ForEach-Object {
        $relative = $_.FullName.Substring($root.Length + 1) -replace '\\', '/'
        if ($Exclude | Where-Object { $relative -like $_ }) { return }
        $target = Join-Path $Destination $relative
        if (Test-Path $target) { return }
        New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
        if ($ConvertDocs -and $_.Extension -eq '.md') {
            [System.IO.File]::WriteAllText((Join-Path (Resolve-Path $Destination).Path $relative), (Convert-ToPowerShellText (Get-Content $_.FullName -Raw)), $script:Utf8NoBom)
        } else {
            Copy-Item $_.FullName $target
        }
    }
}

function New-LinkOrCopy([string]$Path, [string]$Target) {
    if (Test-Path $Path) { return }
    try {
        New-Item -ItemType SymbolicLink -Path $Path -Target $Target -ErrorAction Stop | Out-Null
    } catch {
        $resolved = Join-Path (Split-Path $Path) $Target
        Copy-Item $resolved $Path
        Write-Host "link: $Path copied from $Target because symbolic links are not allowed here"
    }
}

function Add-GitignoreEntry([string]$Entry) {
    if ((Test-Path .gitignore) -and ((Get-Content .gitignore) -contains $Entry)) { return }
    Add-Content .gitignore $Entry
}

function Register-HarnessMcp {
    if (-not (Test-Path .mcp.json)) { return }
    $servers = (Get-Content .mcp.json -Raw | ConvertFrom-Json).mcpServers
    foreach ($agent in 'codex', 'copilot') {
        $executable = Find-Executable $agent
        if (-not $executable) { continue }
        foreach ($server in $servers.PSObject.Properties) {
            & $executable mcp get $server.Name *> $null
            if ($LASTEXITCODE -eq 0) { continue }
            & $executable mcp add $server.Name -- $server.Value.command @($server.Value.args) *> $null
            if ($LASTEXITCODE -eq 0) { Write-Host "mcp: $agent <- $($server.Name)" }
        }
    }
}

function Add-CiSetupStep([string]$Lang) {
    $snippet = Join-Path $script:HarnessTemplates "langs/$Lang.yml"
    $workflow = '.github/workflows/check.yml'
    if (-not ((Test-Path $snippet) -and (Test-Path $workflow))) { return }
    $snippetLines = Get-Content $snippet
    $workflowLines = Get-Content $workflow
    if ($workflowLines -contains $snippetLines[0]) { return }
    $result = foreach ($line in $workflowLines) {
        $line
        if ($line -match 'uses: actions/checkout@') { $snippetLines }
    }
    [System.IO.File]::WriteAllLines((Resolve-Path $workflow).Path, [string[]]$result, $script:Utf8NoBom)
}

function Set-HarnessLang([string]$Lang) {
    $preset = Join-Path $script:HarnessTemplates "langs/$Lang.mk"
    if (-not (Test-Path $preset)) {
        $available = (Get-ChildItem (Join-Path $script:HarnessTemplates 'langs') -Filter *.mk).BaseName -join ','
        Write-Host "unknown -Lang '$Lang'. Available: $available"
        return $false
    }
    $commandLines = [System.Collections.Generic.List[string]](Get-Content commands.mk)
    foreach ($presetLine in Get-Content $preset) {
        $key = [regex]::Escape(($presetLine -split ' :=', 2)[0])
        $index = $commandLines.FindIndex({ param($line) $line -match "^$key := .*set $key in commands\.mk" })
        if ($index -ge 0) { $commandLines[$index] = $presetLine }
    }
    [System.IO.File]::WriteAllLines((Resolve-Path commands.mk).Path, $commandLines, $script:Utf8NoBom)
    Add-CiSetupStep $Lang
    Write-Host "lang: $Lang commands set in commands.mk"
    return $true
}

function Sync-Harness {
    $core = Join-Path $script:HarnessTemplates 'core'
    $overlay = Join-Path $script:HarnessTemplates 'core-ps'
    New-Item -ItemType Directory -Force scripts/agent, .husky | Out-Null
    Copy-Item (Join-Path $core 'scripts/agent/jq') scripts/agent -Recurse -Force
    Copy-Item (Join-Path $overlay 'scripts/agent/*') scripts/agent -Recurse -Force
    Copy-Item (Join-Path $overlay '.husky/*') .husky -Force
    if (-not (Test-Path make.ps1)) {
        Write-Host "sync: make.ps1 and commands.mk are missing. Copy them from $overlay."
    }
    Write-Host 'sync: scripts/agent and .husky updated from the template.'
}

function Invoke-HarnessFill([string]$Cli, [string]$Model) {
    if (-not $Model) { $Model = $script:CheapestModel[$Cli] }
    $prompt = Convert-ToPowerShellText (Get-Content (Join-Path $script:HarnessTemplates 'fill-prompt.md') -Raw)
    $executable = Find-Executable $Cli
    Write-Host "fill: asking $Cli ($Model) to fill the md files"
    switch ($Cli) {
        'claude' { & $executable -p $prompt --model $Model --permission-mode acceptEdits --allowedTools 'Bash(./make.ps1 *)' 'Bash(git log *)' 'Bash(git ls-files *)' }
        'codex' { & $executable exec -m $Model -s workspace-write $prompt }
        'copilot' { & $executable -p $prompt --model $Model --allow-tool=write '--allow-tool=shell(./make.ps1:*)' '--allow-tool=shell(git:*)' '--deny-tool=shell(git push)' }
        'gemini' { & $executable -p $prompt --model $Model --approval-mode auto_edit }
    }
    return $LASTEXITCODE -eq 0
}

function Write-MissingToolWarnings {
    $needs = @{
        jq       = 'scripts/agent needs it (winget install jqlang.jq)'
        gitleaks = 'pre-commit cannot scan (winget install gitleaks.gitleaks)'
    }
    foreach ($tool in $needs.Keys) {
        if (-not (Find-Executable $tool)) { Write-Host "WARNING: $tool is missing; $($needs[$tool])." }
    }
}

function Invoke-Harness {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)][string]$Dir = '.',
        [string]$Lang,
        [switch]$Sync,
        [ValidateSet('claude', 'codex', 'copilot', 'gemini')][string]$Fill,
        [string]$Model
    )

    if ($Lang -and -not (Test-Path (Join-Path $script:HarnessTemplates "langs/$Lang.mk"))) {
        Set-HarnessLang $Lang | Out-Null
        return
    }
    if ($Fill -and -not (Find-Executable $Fill)) {
        Write-Host "-Fill ${Fill}: $Fill is not installed."
        return
    }

    New-Item -ItemType Directory -Force $Dir | Out-Null
    Set-Location $Dir

    if (-not (Test-Path .git)) {
        git init -q
        Write-Host 'git: initialized'
    }

    Copy-TreeWithoutOverwrite (Join-Path $script:HarnessTemplates 'core') . -Exclude $script:BashOnlyFiles -ConvertDocs
    Copy-TreeWithoutOverwrite (Join-Path $script:HarnessTemplates 'core-ps') .
    New-LinkOrCopy 'CLAUDE.md' 'AGENTS.md'
    $script:AgentDirectories | ForEach-Object { New-Item -ItemType Directory -Force $_ | Out-Null }
    New-LinkOrCopy '.github/copilot-instructions.md' '../AGENTS.md'
    Add-GitignoreEntry '.agent/'
    git config core.hooksPath .husky

    Register-HarnessMcp
    if ($Sync) { Sync-Harness }
    if ($Lang -and -not (Set-HarnessLang $Lang)) { return }

    foreach ($directory in $script:AgentDirectories) {
        if (-not (Get-ChildItem $directory -Force)) { New-Item -ItemType File (Join-Path $directory '.gitkeep') | Out-Null }
    }

    Write-MissingToolWarnings

    if (-not $Fill) {
        Write-Host "harness ready in $PWD. Next: fill the commands.mk commands, AGENTS.md, ARCHITECTURE.md."
        return
    }
    if (-not (Invoke-HarnessFill $Fill $Model)) { Write-Host "WARNING: $Fill exited with an error. Review the md files." }
    Write-Host "harness ready in $PWD. Review the filled md files and every 'Unknown:' line."
}

Set-Alias harness Invoke-Harness
