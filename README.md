# .config - Development Environment Configuration

A modern, feature-rich development environment configuration focused on productivity and efficiency. This repository contains my personal configuration files for various development tools.

## 🌟 Key Features

### Neovim Configuration

A powerful Neovim setup with modern features and plugins:

- 🎨 **UI Enhancements**
  - Kanagawa color scheme (dragon theme)
  - Custom status line with Lualine
  - Modern UI elements with Noice
  - Smart notifications with nvim-notify
  - File tree explorer with Neo-tree
  - Buffer management with Bufferline

- ⚡ **Development Features**
  - LSP support with auto-completion
  - Treesitter for better syntax highlighting
  - Fuzzy finding with Telescope
  - Git integration with Gitsigns
  - Smart bracket pairing with mini.pairs
  - Advanced indent guides
  - Word highlighting with vim-illuminate

- ⌨️ **Key Bindings**
  - Space as leader key
  - Intuitive window navigation
  - Easy buffer management
  - Quick file operations
  - Git workflow shortcuts
  - LSP integration shortcuts

## 📦 Core Components

### Plugin Management
- Uses `lazy.nvim` for efficient plugin management
- Lazy-loading for optimal startup time

### File Structure
```
.config/
├── nvim/
│   │   ├── lua/
│   │   │   ├── core/           # Core Neovim configurations
│   │   │   │   ├── init.lua    # Main initialization
│   │   │   │   ├── options.lua # General settings
│   │   │   │   ├── keymaps.lua # Key mappings
│   │   │   │   └── autocmds.lua# Autocommands
│   │   │   └── plugins/        # Plugin configurations
│   │   │       └── core/       # Core plugin setups
└── README.md
```

## ⚡ Quick Start

1. Clone this repository to your `.config` directory:
   ```bash
   git clone https://github.com/yourusername/.config.git ~/.config
   ```

2. Install Neovim (version 0.9.0 or later)

3. First launch will automatically:
   - Install lazy.nvim (plugin manager)
   - Install configured plugins
   - Set up LSP servers and tools


## 🛠 Customization

The configuration is modular and easy to customize:

- Edit `core/options.lua` for Neovim settings
- Modify `core/keymaps.lua` for key bindings
- Adjust plugin configs in `plugins/core/`

## 📦 Dependencies

- Neovim >= 0.9.0
- Git
- A Nerd Font
- ripgrep (for telescope grep)
- Node.js (for LSP servers)
- Python 3 (for some plugins)

## 🎨 Theme and Styling

Uses the Kanagawa color scheme with:
- Dragon theme variant
- Transparent background
- Custom status line styling
- Modern UI elements
- Consistent icons


## 📝 License

This project is open-source and available under the MIT License.
