# AGENTS.md - Agentic Coding Guidelines

This repository contains dotfiles/configs for various tools. Agents should read this file.

## Repository Structure

```
~/.config/
├── aerospace/     # Window manager (TOML)
├── calcure/      # Calendar (personal, in .gitignore)
├── ghostty/       # Terminal config
├── nvim/         # Neovim config (Lua)
├── tmux/         # Tmux config
├── zshrc/        # Zsh configuration
├── CHANGELOG.md  # Change log
└── .gitignore    # Ignore stripe/, calcure/
```

## Build/Lint/Test Commands

### Neovim (Lua)
```bash
stylua nvim/lua/                      # Format (col=120, indent=2, single quotes)
nvim --headless -c "lua vim.cmd('quitall')" 2>&1  # Check config
```

### Shell Scripts
```bash
shellcheck zshrc/.zshrc     # Lint
zsh -n zshrc/.zshrc        # Syntax check
```

### Flutter/Android
```bash
flutter analyze                      # Analyze
flutter test test/path/to/file_test # Single test
./gradlew lintDebug               # Lint
emulator -list-avds              # List emulators
```

### .NET
```bash
dotnet build                              # Build
dotnet test --filter "FullyQualifiedName~X.Y" # Single test
dotnet test --logger "console;verbosity=detailed" # Verbose
```

### Go
```bash
go fmt ./...  # Format
go build .   # Build
go test .    # Test
```

## Code Style Guidelines

### General Principles
1. **Security first**: Never commit secrets/API keys
2. **Keep it simple**: Prefer clarity over cleverness
3. **Consistency**: Match existing patterns

### Lua (nvim/.stylua.toml)
- **Column width**: 120, **Indentation**: 2 spaces, **Quotes**: single
- **Call parens**: Match input style `require("foo")` vs `require "foo"`

```lua
return {
  "plugin/name",
  dependencies = { "dep1" },
  ft = { "filetype" },
  event = { "EventName" },
  build = ":lua require('mod').fn()",
  opts = { key = value },
  config = function(_, opts)
    require("mod").setup(opts)
  end,
}
```

Naming: `snake_case.lua`, modules like `sylow.plugins.langs.go`

### Zsh (zshrc/.zshrc)
- **Line length**: 100 max, **Indentation**: 2 spaces
- **Functions**: `function name()` (not `function name`)
- **Conditionals**: `[[ ]]` not `[ ]`, double quotes for vars

```zsh
function fn() {
  if [ ! -f "$1" ]; then
    echo "Error: File not found: $1"
    return 1
  fi
}
```

### Tmux (tmux/tmux.conf)
- `set-option -g key value`, `bind key command`, `bind -r key` (repeatable)
- Colors: hex without `#` (e.g., `"181616"`)

### TOML (Aerospace, Ghostty)
- No trailing commas, strings double quotes, booleans lowercase

### Git Commits
Format: `<type>(<scope>): <description>`

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`

## Neovim Plugin Structure
```
nvim/lua/sylow/
├── core/          # options, keymaps, autocmds
├── plugins/      # ai/, code/, debugger/, editor/, git/, langs/, ui/
└── utils/       # Helpers
```

## Error Handling
```lua
local ok, err = pcall(require, "module")
if not ok then
  vim.notify("Error: " .. err, vim.log.LEVEL.ERROR)
  return
end
```

## Key Tools
- Neovim (Mason), Flutter, .NET, Go, Bun, Node (nvm), Rust
- Plugins: `nvim-lspconfig`, `mason.nvim`, `conform.nvim`, `nvim-cmp`, `copilot.lua`, `telescope.nvim`

## Environment Variables
- `EDITOR`/`SQL_EDITOR`: `nvim`
- `DOTNET_ROOT`: `$HOME/.dotnet`
- `ANDROID_HOME`: `$HOME/Library/Android/sdk`
- `GOPATH`: `$HOME/go`
- `NVM_DIR`: `$HOME/.nvm`

## Tips
1. Check CHANGELOG.md first
2. Match existing patterns
3. Run lint/check commands
4. Don't commit secrets (check .gitignore)