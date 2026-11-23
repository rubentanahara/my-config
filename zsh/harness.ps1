$script:HarnessTemplates = Join-Path $PSScriptRoot 'harness-templates'
$script:CheapestModel = @{ claude = 'haiku'; codex = 'gpt-6-luna'; copilot = 'auto'; agy = 'gemini-3.8-flash-low' }
$script:AgentDirectories = '.claude/skills', '.claude/agents', '.claude/hooks', '.claude/commands', '.claude/workflows', '.claude/routines',
    '.github/agents', '.github/prompts', '.github/instructions', '.github/workflows', '.github/hooks'
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Find-Executable([string]$Name) {
    Get-Command $Name -CommandType Application, ExternalScript -ErrorAction SilentlyContinue | Select-Object -First 1
}

$script:BashOnlyFiles = 'Makefile', 'scripts/agent/*.sh', '.husky/*', '.claude/settings.json', '.codex/hooks.json', '.agents/hooks.json', '.github/workflows/check.yml'
$script:SyncedSettings = '.claude/settings.json', '.codex/hooks.json', '.agents/hooks.json'

function Convert-ToPowerShellText([string]$Text) {
    $Text = $Text -replace '\b(feature|session-start|stop-gate|tdd-gate|tree-fingerprint|protect-main|run)\.sh\b', '$1.ps1'
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
        Copy-Item $resolved $Path -Recurse
        Write-Host "link: $Path copied from $Target because symbolic links are not allowed here"
    }
}

function Add-GitignoreEntry([string]$Entry) {
    if ((Test-Path .gitignore) -and ((Get-Content .gitignore) -contains $Entry)) { return }
    Add-Content .gitignore $Entry
}

function Register-HarnessMcp {
    if (-not (Test-Path .mcp.json) -or -not (Find-Executable jq)) { return }
    New-Item -ItemType Directory -Force .codex, .agents | Out-Null
    $codexConfig = if (Test-Path .codex/config.toml) { @(Get-Content .codex/config.toml) } else { @() }
    foreach ($name in jq -r '.mcpServers | keys[]' .mcp.json) {
        if ($codexConfig -contains "[mcp_servers.$name]") { continue }
        jq -r --arg n $name '.mcpServers[$n] | "\n[mcp_servers.\($n)]\ncommand = \(.command | tojson)\nargs = \(.args // [] | tojson)"' .mcp.json | Add-Content .codex/config.toml
    }
    New-LinkOrCopy '.agents/mcp_config.json' '../.mcp.json'
    Write-Host 'mcp: project-level only. claude and copilot read .mcp.json, agy reads .agents/mcp_config.json (a link to it), codex reads .codex/config.toml.'
}

function Write-TextFileNoBom([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText([System.IO.Path]::Combine((Get-Location).Path, $Path), $Text, $script:Utf8NoBom)
}

function Initialize-Codegraph {
    if (Test-Path .codegraph) { return }
    $codegraph = Find-Executable codegraph
    if (-not $codegraph) { Write-Host 'WARNING: codegraph is missing; the code index was not built (see the codegraph README to install it).'; return }
    New-Item -ItemType Directory -Force .agent | Out-Null
    & $codegraph init -y *> .agent/codegraph-init.log
    if ($LASTEXITCODE -eq 0) { Write-Host 'codegraph: indexed. The MCP server keeps it in sync while it runs.' } else { Write-Host 'WARNING: codegraph init failed. Log: .agent/codegraph-init.log' }
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
    foreach ($directory in '.claude/skills', '.claude/agents') {
        $root = (Resolve-Path (Join-Path $core $directory)).Path
        Get-ChildItem $root -Recurse -File | ForEach-Object {
            $target = "$directory/" + ($_.FullName.Substring($root.Length + 1) -replace '\\', '/')
            Sync-HarnessFile $target (Convert-ToPowerShellText (Get-Content $_.FullName -Raw))
        }
    }
    foreach ($settings in $script:SyncedSettings) {
        Sync-HarnessFile $settings (Get-Content (Join-Path $overlay $settings) -Raw)
    }
    if (-not (Test-Path make.ps1)) {
        Write-Host "sync: make.ps1 and commands.mk are missing. Copy them from $overlay."
    }
    Write-Host 'sync: scripts/agent and .husky updated from the template.'
    & ./make.ps1 hooks
}

function Sync-HarnessFile([string]$Target, [string]$TemplateText) {
    if (-not (Test-Path $Target)) {
        New-Item -ItemType Directory -Force (Split-Path $Target) | Out-Null
        Write-TextFileNoBom $Target $TemplateText
        Write-Host "sync: added $Target"
        return
    }
    $templateFile = New-TemporaryFile
    try {
        Write-TextFileNoBom $templateFile.FullName $TemplateText
        if ((Get-Content $templateFile.FullName -Raw) -eq (Get-Content $Target -Raw)) { return }
        if ([Console]::IsInputRedirected) {
            Write-Host "sync: kept $Target, which differs from the template. Run Invoke-Harness -Sync in a terminal to review it."
            return
        }
        git --no-pager diff --no-index -- $Target $templateFile.FullName
        if ((Read-Host "sync: replace $Target with the template above? [y/N]") -eq 'y') {
            Write-TextFileNoBom $Target $TemplateText
            Write-Host "sync: replaced $Target"
        } else {
            Write-Host "sync: kept $Target"
        }
    } finally {
        Remove-Item $templateFile.FullName -Force
    }
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
        'agy' { & $executable -p $prompt --model $Model --mode auto --sandbox }
    }
    return $LASTEXITCODE -eq 0
}

function Write-FillReport {
    $pattern = '^<One line|set [A-Z_]+ in commands\.mk|^- [^:]+:$|^\| \| \||what lives here|YYYY-MM-DD|Unknown:'
    $left = @(Select-String -Path AGENTS.md, ARCHITECTURE.md, SECURITY.md, PROGRESS.md, commands.mk -Pattern $pattern -ErrorAction SilentlyContinue)
    if ($left.Count -eq 0) {
        Write-Host 'fill: every field is filled.'
        return
    }
    Write-Host 'fill: these lines are still empty or Unknown. A person must fill or confirm them:'
    $left | ForEach-Object { Write-Host "$($_.Filename):$($_.LineNumber):$($_.Line)" }
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
        [ValidateSet('claude', 'codex', 'copilot', 'agy')][string]$Fill,
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
    New-Item -ItemType Directory -Force .agents | Out-Null
    New-LinkOrCopy '.agents/skills' '../.claude/skills'
    Add-GitignoreEntry '.agent/'
    Add-GitignoreEntry '.worktrees/'
    git config core.hooksPath .husky

    Register-HarnessMcp
    Initialize-Codegraph
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
    Write-FillReport
    Write-Host "harness ready in $PWD. Review the filled md files."
}

Set-Alias harness Invoke-Harness
