local options = {}

function options.setup()
  -- BASE OPTIONS CONFIGURATION
  local opt = vim.opt -- for concise set options
  local g = vim.g     -- for concise set global variables

  -- Global options
  g.mapleader = ' ' -- set leader key to space
  g.autoformat = false
  g.disable_autoformat = true

  -- Encoding
  vim.scriptencoding = 'utf-8'
  opt.fileencoding = 'utf-8'
  opt.encoding = 'utf-8'

  -- UI
  opt.number = true
  opt.relativenumber = true
  opt.termguicolors = true
  -- opt.cursorline = true
  opt.signcolumn = 'yes'
  opt.colorcolumn = '80'
  opt.showmode = true
  opt.showcmd = false
  opt.conceallevel = 2
  opt.laststatus = 3
  opt.cmdheight = 1

  -- Editing
  opt.expandtab = true
  opt.shiftwidth = 2
  opt.tabstop = 2
  opt.smartindent = true
  opt.wrap = false
  opt.breakindent = true
  opt.showbreak = string.rep(' ', 3)
  opt.linebreak = true

  -- Behavior
  opt.hidden = true
  opt.errorbells = false
  opt.swapfile = false
  opt.backup = false
  opt.undofile = true
  opt.undodir = vim.fn.stdpath 'data' .. '/undodir'
  opt.ignorecase = true
  opt.smartcase = true
  opt.clipboard = 'unnamedplus'
  opt.completeopt = 'menuone,noselect'
  opt.updatetime = 250
  opt.timeoutlen = 300
  opt.splitright = true
  opt.splitbelow = true

  -- Search
  opt.hlsearch = true
  opt.incsearch = true

  -- Performance
  opt.redrawtime = 1500
  opt.timeoutlen = 250
  opt.updatetime = 250

  -- Window
  opt.scrolloff = 8
  opt.sidescrolloff = 8

  -- Wild menu
  opt.wildmode = 'longest:full,full'
  opt.wildignore = '*/node_modules/*,*/dist/*,*/.git/*'

  -- Shell
  opt.shell = 'zsh'
end

return options
