--@diagnostic disable: missing-fields
local M = {}
local _vim = vim
local opt = _vim.opt
local g = _vim.g

-- Check if vim is available
function M.setup()
  _vim.o.background = 'dark' -- Set background to dark.

  -- Globals --------------------------------------------------------------------

  g.mapleader = " "                                  -- Leader key.
  g.maplocalleader = " "                             -- Leader key.
  g.autoformat = true                               -- Disable autoformatting for all filetypes.
  g.scriptencoding = 'utf-8'
  g.big_file = { size = 1024 * 5000, lines = 50000 } -- For files bigger than this, disable 'treesitter' (+5Mb).
  g.disable_autoformat = false                        -- Disable autoformatting for all filetypes
  g.autoformat_enabled = false                       -- Enable auto formatting at start.
  g.autopairs_enabled = false                        -- Enable autopairs at start.
  g.cmp_enabled = true                               -- Enable completion at start.
  g.codeactions_enabled = true                       -- Enable displaying 💡 where code actions can be used.
  g.codelens_enabled = true                          -- Enable automatic codelens refreshing for lsp that support it.
  g.diagnostics_mode = 3                             -- Set code linting (0=off, 1=only show in status line, 2=virtual text off, 3=all on).
  g.fallback_icons_enabled = false                    -- Enable it if you need to use Neovim in a machine without nerd fonts.
  g.inlay_hints_enabled = true                      -- Enable always show function parameter names.
  g.lsp_round_borders_enabled = true                 -- Enable round borders for lsp hover and signatureHelp.
  g.lsp_signature_enabled = true                     -- Enable automatically showing lsp help as you write function parameters.
  g.notifications_enabled = true                     -- Enable notifications.
  g.semantic_tokens_enabled = true                   -- Enable lsp semantic tokens at start.
  g.url_effect_enabled = true                        -- Highlight URLs with an underline effect.

  -- Options --------------------------------------------------------------------

  -- Encoding
  opt.fileencoding = 'utf-8' -- The encoding written to file.
  opt.encoding = 'utf-8'     -- The encoding used internally by Vim.

  -- UI
  opt.termguicolors = true -- Enable 24-bit RGB colors.
  opt.number = true -- Show line numbers.
  opt.relativenumber = true -- Relative line numbers.
  opt.preserveindent = true -- Preserve indent for autoindents.
  opt.pumheight = 10 -- Height of pop up menu.
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
  -- opt.cursorline = true -- Highlight the line with the cursor.
  opt.guicursor = "n:blinkon200,i-ci-ve:ver25" -- Enable cursor blink.
  opt.signcolumn = 'yes' -- Always show sign column.
  opt.colorcolumn = '' -- Disable color column.
  opt.showmode = true -- Show mode in the last line of the screen.
  opt.showcmd = true -- Show command in the last line of the screen.
  opt.showtabline = 2 -- Always show tabs.
  opt.conceallevel = 2 -- Conceal level for markdown.
  opt.laststatus = 3 -- Global status line.
  opt.cmdheight = 0 -- Height of command line.

  -- Editing
  opt.expandtab = true               -- Use spaces instead of tabs.
  opt.copyindent = true              -- Copy the previous indentation on autoindenting.
  opt.shiftwidth = 2                 -- Number of spaces to use for each step of (auto)indent.
  opt.tabstop = 2                    -- Number of spaces that a <Tab> counts for.
  opt.smartindent = true             -- Enable smart indentation.
  opt.winminwidth = 5                -- Minimum window width
  opt.wrap = false                   -- Disable line wrapping.
  opt.breakindent = true             -- Enable break indent.
  opt.showbreak = string.rep(' ', 3) -- String to show at the beginning of wrapped lines.
  opt.linebreak = true               -- Break lines at word boundaries.

  -- Behavior
  opt.hidden = true                                   -- Allow switching buffers without saving.
  opt.errorbells = false                              -- No error bells.
  opt.swapfile = false                                -- No swap files.
  opt.backup = false                                  -- No backup files.
  opt.undofile = true                                 -- Enable persistent undo.
  opt.undodir = _vim.fn.stdpath 'data' .. '/undodir'  -- Directory for undo files.
  opt.ignorecase = true                               -- Case insensitive searching.
  opt.infercase = true                                -- Infer cases in keyword completion.
  opt.smartcase = true                                -- Case sensitive searching when uppercase letters are used.
  opt.clipboard = 'unnamedplus'                       -- Use system clipboard.
  opt.completeopt = { "menu", "menuone", "noselect" } -- Options for insert mode completion.
  opt.splitright = true                               -- Split windows to the right.
  opt.splitbelow = true                               -- Split windows to the right and below.

  -- Search
  opt.hlsearch = true  -- Highlight all matches on previous search pattern.
  opt.incsearch = true -- Incremental search.

  -- Performance
  opt.redrawtime = 1500 -- Time in milliseconds to redraw the screen.
  opt.timeoutlen = 300  -- Time to wait for a mapped sequence to complete (in milliseconds).
  opt.updatetime = 300  -- Faster completion (4000ms default).

  -- Window
  opt.scrolloff = 8     -- Lines of context to keep above and below the cursor.
  opt.sidescrolloff = 8 -- Lines of context to keep above and below the cursor.

  -- Wild menu
  opt.wildmode = 'longest:full,full'                    -- Command-line completion mode.
  opt.wildignore = '*/node_modules/*,*/dist/*,*/.git/*' -- Ignore node_modules and dist folders.

  -- Shell
  opt.shell = 'zsh'                                            -- Set shell to zsh.

  opt.viewoptions:remove "curdir"                              -- Disable saving current directory with views.
  opt.shortmess:append { s = true, I = true }                  -- Disable startup message.
  opt.backspace:append { "nostop" }                            -- Don't stop backspace at insert.
  opt.diffopt:append { "algorithm:histogram", "linematch:60" } -- Enable linematch diff algorithm
end

return M
