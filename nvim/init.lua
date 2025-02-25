-- Set up leader key early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable termguicolors for proper color support
vim.opt.termguicolors = true

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set up core configuration
require("core").setup()

-- Initialize plugins
require("lazy").setup({
  spec = {
    { import = "plugins.core.ui" },     -- UI components (including theme) must be first
    { import = "plugins.core.editor" }, -- Editor essentials
    { import = "plugins.core.coding" }, -- Basic coding features
    { import = "plugins.core.lsp" },    -- LSP core setup
    { import = "plugins.core.debug" },  -- Debugging setup
    { import = "plugins.core.tmux" },   -- Tmux integration
    { import = "plugins.core.util" },   -- Additional utilities
  },
  defaults = {
    lazy = true,                -- Every plugin is lazy-loaded by default
    version = false,            -- Try installing the latest stable versions of plugins
  },
  checker = { enabled = true }, -- Automatically check for plugin updates
  performance = {
    rtp = {
      -- Disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🔑",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "󰒲 ",
    },
  },
})
