# Changelog

## [Unreleased] - 2026-04-22

### Security
- Added `stripe/` and `calcure/` to `.gitignore` to prevent sensitive API keys and personal calendar data from being committed

### Aerospace
- Disabled window gaps (inner/outer) — commented out `[gaps]` section for a denser layout
- Added `alt-f` keybinding to launch Figma

### Ghostty
- Re-enabled window decorations (`window-decoration=true`)
- Commented out hidden titlebar (`macos-titlebar-style = hidden`)
- Added white cursor color (`cursor-color = #ffffff`)
- Added VS Code-style text selection colors (`#264F78` background, `#ffffff` foreground)

### Neovim — AI
- Fixed Copilot `<Tab>` accept conflict with nvim-cmp: set `accept = false` in copilot.lua and added `copilot.suggestion.is_visible()` check as the first priority in cmp's Tab mapping

### Neovim — Go
- Added `go.nvim` plugin with `ray-x/guihua.lua` dependency, triggered on `go`/`gomod` filetypes
- Configured `goimports` on `BufWritePre` via autocmd
- Disabled `lsp_codelens` to prevent `vim.lsp.codelens.enable` nil error on Neovim < 0.10
- Added full `gopls` LSP configuration: analyses (unusedparams, shadow, unusedvariable), staticcheck, gofumpt, usePlaceholders, completeUnimported, all codelenses, and full inlay hints suite

### Neovim — C# / .NET
- Enabled `easy-dotnet.nvim` plugin (was commented out) with background scanning
- Fixed C# debugger: changed `netcoredbg-macOS-arm64.setup(dap)` → `setup()` (no argument)
- Fixed DLL picker call: `build_dll_path()` → `smart_dll_picker()`

### Neovim — Dart / Flutter
- Enabled Flutter debugger (`debugger.enabled = true`)
- Fixed `pubspec-assist` setup call: `setup()` → `setup({})` to pass empty opts table

### Neovim — Editor / Formatting
- Dropped `biome` from JS/TS formatters in conform.nvim (now uses `prettier` only)
- Added explicit `javascriptreact` and `typescriptreact` formatter entries

### Neovim — Markdown
- Enabled PlantUML headless flag: `cli_args = { '-Djava.awt.headless=true' }`
- Added `nvim-web-devicons` as explicit dependency for render-markdown
- Removed `nabla.nvim` (LaTeX math popup) — plugin deleted
- Removed commented-out `vimtex` block — cleaned up dead config

### Neovim — UI
- Added `snacks.nvim` (`folke/snacks.nvim`) with GitHub Issues/PR pickers:
  - `<leader>gi` — open issues, `<leader>gI` — all issues
  - `<leader>gp` — open PRs, `<leader>gP` — all PRs
- Disabled `which-key.nvim` entirely — plugin returns `{}`, full config commented out for removal
- Added commented-out alternative colorscheme configs (kanagawa-paper, vscode) for reference

### Neovim — Plugin Versions
- Updated `lazy-lock.json`: bumped LuaSnip, conform, copilot, crates, dashboard, diagram, kanagawa, lazydev, lualine, mason-lspconfig, mason, mini.*, neo-tree, neotest, nvim-cmp, nvim-colorizer, nvim-dap, nvim-lspconfig, nvim-treesitter, plenary, render-markdown, roslyn, telescope, and more
- Added new lock entries: `go.nvim`, `guihua.lua`, `easy-dotnet.nvim`, `snacks.nvim`
- Removed `which-key.nvim` lock entry

### Tmux
- Added `bind -r b` → lazysql popup (80%×80%, current path)
- Removed `bind -r j` (journal popup) and `bind -r e` (notes popup)
- Fixed `gh dash` quoting in `bind -r t`

### Zsh
- Added `SQL_EDITOR=nvim` export for lazysql integration
- Fixed `flutter-watch`: now opens a horizontal split first, starts nodemon with `ulimit -n 65536` and a PID-file guard, then runs `flutter run` in the original pane
- Renamed `vprojects` alias → `vplanner`; updated `vp()` function to write to `planner/` directory
- New `vw()` function: creates a weekly planner from `templates/weekly.md`, fills in week number and date range, opens in nvim
- Updated `dev` alias to also invoke `devtmx` after changing directory
- New `wifipass()` function: retrieves the saved WiFi password for the current (or specified) network via macOS Keychain
- Added opencode to `PATH` and exported `LOGINPOC_DB_ADMIN_PASSWORD`, `NEW_RELIC_LICENSE_KEY`, `CHAOS_ENABLED`
- Added `claude-mem` alias pointing to the claude-mem worker service script
- Added bun shell completions

### New Tools
- Added `lazysql/config.toml` with production (read-only) and development MySQL database connections, page size 300
