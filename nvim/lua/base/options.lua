---@diagnostic disable: missing-fields
local M = {}

function M.setup()
  local utils = require("base").utils

  local _vim = vim
  if not _vim then
    utils.notify("vim is not available")
  end

  local opt = _vim.opt
  local g = _vim.g

  -- Globals --------------------------------------------------------------------

  g.mapleader = ' ' -- Set leader key to space
  g.autoformat = false
  g.scriptencoding = 'utf-8'
  g.maplocalleader = ","                             -- Set default local leader key.
  g.big_file = { size = 1024 * 5000, lines = 50000 } -- For files bigger than this, disable 'treesitter' (+5Mb).
  g.disable_autoformat = true
  g.autoformat_enabled = false                       -- Enable auto formatting at start.
  g.autopairs_enabled = false                        -- Enable autopairs at start.
  g.cmp_enabled = true                               -- Enable completion at start.
  g.codeactions_enabled = true                       -- Enable displaying 💡 where code actions can be used.
  g.codelens_enabled = true                          -- Enable automatic codelens refreshing for lsp that support it.
  g.diagnostics_mode = 3                             -- Set code linting (0=off, 1=only show in status line, 2=virtual text off, 3=all on).
  g.fallback_icons_enabled = false                   -- Enable it if you need to use Neovim in a machine without nerd fonts.
  g.inlay_hints_enabled = false                      -- Enable always show function parameter names.
  g.lsp_round_borders_enabled = true                 -- Enable round borders for lsp hover and signatureHelp.
  g.lsp_signature_enabled = true                     -- Enable automatically showing lsp help as you write function parameters.
  g.notifications_enabled = true                     -- Enable notifications.
  g.semantic_tokens_enabled = true                   -- Enable lsp semantic tokens at start.
  g.url_effect_enabled = true                        -- Highlight URLs with an underline effect.

  -- Options --------------------------------------------------------------------

  -- Encoding
  opt.fileencoding = 'utf-8'
  opt.encoding = 'utf-8'

  -- UI
  opt.number = true
  opt.relativenumber = true
  opt.preserveindent = true
  opt.pumheight = 10 -- Height of pop up menu.
  opt.termguicolors = true
  opt.fillchars = {
    eob = " ", -- Character to display at the end of the buffer
    fold = "", -- Character to indicate a folded line
    foldopen = "", -- Character to indicate an open fold
    foldclose = "", -- Character to indicate a closed fold
    foldsep = "│", -- Separator between folded lines
    diff = "╱", -- Character to indicate differences in diff mode
    vert = "│", -- Vertical separator for splits
  }
  opt.foldenable = true -- Enable fold for nvim-ufo.
  opt.foldlevel = 99 -- set highest foldlevel for nvim-ufo.
  opt.foldcolumn = "1" -- Show foldcolumn in nvim 0.9+.
  opt.cursorline = true
  opt.guicursor = "n:blinkon200,i-ci-ve:ver25" -- Enable cursor blink.
  opt.signcolumn = 'yes'
  opt.colorcolumn = ''
  opt.showmode = true
  opt.showcmd = false
  opt.showtabline = 2
  opt.conceallevel = 2
  opt.laststatus = 3
  opt.cmdheight = 1
  _vim.o.background = 'dark'

  -- Editing
  opt.expandtab = true
  opt.copyindent = true -- Copy the previous indentation on autoindenting.
  opt.shiftwidth = 2
  opt.tabstop = 2
  opt.smartindent = true
  opt.winminwidth = 5 -- Minimum window width
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
  opt.undodir = _vim.fn.stdpath 'data' .. '/undodir'
  opt.ignorecase = true -- Case insensitive searching.
  opt.infercase = true  -- Infer cases in keyword completion.
  opt.smartcase = true
  opt.clipboard = 'unnamedplus'
  opt.completeopt = { "menu", "menuone", "noselect" } -- Options for insert mode completion.
  opt.splitright = true
  opt.splitbelow = true

  -- Search
  opt.hlsearch = true
  opt.incsearch = true

  -- Performance
  opt.redrawtime = 1500
  opt.timeoutlen = 300
  opt.updatetime = 300

  -- Window
  opt.scrolloff = 8
  opt.sidescrolloff = 8

  -- Wild menu
  opt.wildmode = 'longest:full,full'
  opt.wildignore = '*/node_modules/*,*/dist/*,*/.git/*'

  -- Shell
  opt.shell = 'zsh'

  opt.viewoptions:remove "curdir"                              -- Disable saving current directory with views.
  opt.shortmess:append { s = true, I = true }                  -- Disable startup message.
  opt.backspace:append { "nostop" }                            -- Don't stop backspace at insert.
  opt.diffopt:append { "algorithm:histogram", "linematch:60" } -- Enable linematch diff algorithm
end

return M
