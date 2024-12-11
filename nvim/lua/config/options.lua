-- BASE OPTIONS CONFIGURATION

local opt = vim.opt -- for concise set options
local g = vim.g -- for concise set global variables
g.mapleader = " " -- set leader key to space
g.autoformat = false
-- encoding
vim.scriptencoding = "utf-8"
opt.fileencoding = "utf-8"
opt.encoding = "utf-8"

-- numbers
opt.relativenumber = true -- relative line numbers
opt.number = true -- show line numbers
opt.ruler = false -- show cursor position

-- tabs
opt.title = true -- show title in titlebar
opt.expandtab = true -- use spaces instead of tabs
opt.smarttab = true -- use shiftwidth when inserting tab

-- indentation
opt.tabstop = 4 -- tab width
opt.softtabstop = 4 -- tab width when editing
opt.shiftwidth = 4 -- indent width
opt.smartindent = true -- autoindent new lines
opt.autoindent = true -- autoindent new lines\
opt.breakindent = true -- indent wrapped lines
opt.inccommand = "split" -- don't split lines in command mode

-- scrolling
opt.fillchars = { eob = " " } -- fill end of buffer with spaces

opt.mouse = "a" -- enable mouse

-- line wrapping
opt.wrap = true --wrap lines

-- search
opt.ignorecase = true -- ignore case
opt.smartcase = true -- ignore case unless there is a capital letter
opt.incsearch = true -- show search matches as you type
opt.hlsearch = true -- highlight search matches

-- appearance
opt.cmdheight = 1 -- more space for displaying messages
opt.showmode = true -- show current mode
opt.showcmd = true -- show current command
opt.laststatus = 3 -- always show status line
opt.termguicolors = true -- enable 24-bit RGB colors
opt.background = "dark" -- dark background
opt.scrolloff = 10 -- minimum lines to keep above and below cursor
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- split
opt.splitbelow = true -- split below instead of above
opt.splitright = true -- split right instead of left

-- turn off swapfiles
opt.swapfile = false -- don't use swap files

-- clipboard
opt.clipboard = "unnamedplus" -- use system clipboard
opt.cursorline = false -- highlight current line

-- backspace
opt.backspace = "indent,eol,start" -- backspace through everything

-- backup
opt.backup = false -- don't backup files
opt.backupskip = { "/tmp/*", "/private/tmp/*" } -- don't backup files
opt.swapfile = false -- don't use swap files

-- undo
opt.undofile = true -- enable undo files

-- shell
opt.shell = "zsh" -- use zsh as shell

opt.whichwrap:append("<>[]hl") -- move to next line with these keys
