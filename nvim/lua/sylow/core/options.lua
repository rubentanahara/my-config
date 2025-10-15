local opt = vim.opt
local g = vim.g
local utils = require('sylow.utils')

function _G.statusLine()
  return g.flutter_tools_decorations.app_version
end
opt.statusline = '%!v:statusLine()'

-- Globals
vim.o.background = 'dark'                          -- Set the overall color theme to dark mode
g.mapleader = ' '                                  -- Set space as the leader key for custom mappings
g.maplocalleader = '\\'                            -- Set backslash as the local leader key
g.autoformat = false                               -- Disable autoformatting for all filetypes.
g.scriptencoding = 'utf-8'
g.big_file = { size = 1024 * 5000, lines = 50000 } -- For files bigger than this, disable 'treesitter' (+5Mb).
g.autoformat_enabled = false                       -- Enable auto formatting at start.
g.autopairs_enabled = true                         -- Enable autopairs at start.
g.cmp_enabled = true                               -- Enable completion at start.
g.codeactions_enabled = true                       -- Enable displaying 💡 where code actions can be used.
g.codelens_enabled = true                          -- Enable automatic codelens refreshing for lsp that support it.
g.diagnostics_mode = 3                             -- Set code linting (0=off, 1=only show in status line, 2=virtual text off, 3=all on).
g.fallback_icons_enabled = false                   -- Enable it if you need to use Neovim in a machine without nerd fonts.
g.inlay_hints_enabled = true                       -- Enable always show function parameter names.
g.lsp_round_borders_enabled = true                 -- Enable round borders for lsp hover and signatureHelp.
g.lsp_signature_enabled = true                     -- Enable automatically showing lsp help as you write function parameters.
g.notifications_enabled = true                     -- Enable notifications.
g.semantic_tokens_enabled = true                   -- Enable lsp semantic tokens at start.
g.url_effect_enabled = true                        -- Highlight URLs with an underline effect.
g.markdown_recommended_style = 0                   -- Disable default markdown style to allow custom formatting
g.default_colorscheme = 'kanagawa-dragon'

-- Encoding
opt.fileencoding = 'utf-8' -- Set encoding for written files
opt.encoding = 'utf-8'     -- Set encoding for Neovim interface

-- UI
opt.termguicolors = true -- Enable 24-bit RGB color in the TUI
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers for easier navigation
opt.preserveindent = true -- Preserve indent structure when reindenting
opt.pumheight = 10 -- Maximum number of items to show in the popup menu
opt.fillchars = {
  eob = ' ', -- Character to display at the end of the buffer
  fold = utils.get_icon('FoldClosed'), -- Character to indicate a folded line
  foldopen = utils.get_icon('FoldOpened'), -- Character to indicate an open fold
  foldclose = utils.get_icon('FoldClosed'), -- Character to indicate a closed fold
  foldsep = utils.get_icon('Indent'), -- Separator between folded lines
  diff = '╱', -- Character to indicate differences in diff mode
  -- vert = "│", -- Vertical separator for splits
}
opt.selection = 'old'  -- Don't select the newline symbol when using <End> on visual mode.
opt.foldenable = true  -- Enable folding
opt.foldlevel = 99     -- Start with all folds open
opt.foldcolumn = '0'   -- Show fold column with width of 1
opt.cursorline = false -- Highlight the current line
opt.signcolumn = 'yes' -- Always show sign column for diagnostics
opt.colorcolumn = ''   -- No color column for line length indication
opt.showmode = true    -- Show current mode (INSERT, VISUAL, etc.)
opt.showcmd = true     -- Show partial commands in the last line
opt.showtabline = 2    -- Always show the tab line
opt.conceallevel = 2   -- Hide concealed text unless replacement character provided
opt.laststatus = 3     -- Global status line
opt.cmdheight = 0      -- Hide command line when not in use

-- Editing
opt.expandtab = true               -- Convert tabs to spaces
opt.copyindent = true              -- Copy the structure of existing lines indent when autoindenting
opt.shiftround = true              -- Round indent to multiple of shiftwidth
opt.shiftwidth = 2                 -- Number of spaces for each indent level
opt.tabstop = 2                    -- Number of spaces that a <Tab> counts for
opt.ruler = false                  -- Hide cursor position info in command line
opt.smartindent = true             -- Insert indents automatically after certain characters
opt.winminwidth = 5                -- Minimum width of a window when it's not current
opt.wrap = false                   -- Don't wrap lines
opt.breakindent = true             -- Wrapped lines preserve indentation
opt.showbreak = string.rep(' ', 3) -- Show 3 spaces at start of wrapped lines
opt.linebreak = true               -- Break long lines at word boundaries
opt.confirm = true                 -- Ask for confirmation before closing unsaved buffers
opt.virtualedit = 'block'          -- Allow cursor to move beyond end of line in visual block mode
opt.inccommand = 'nosplit'         -- Show live substitution preview inline
opt.jumpoptions = 'view'           -- Maintain view when using jump commands

-- Behavior
opt.hidden = true                                 -- Allow switching buffers without saving
opt.errorbells = false                            -- Disable error bells
opt.swapfile = false                              -- Don't create swap files
opt.backup = false                                -- Don't create backup files
opt.undofile = true                               -- Enable persistent undo
opt.undodir = vim.fn.stdpath 'data' .. '/undodir' -- Directory for undo history
opt.formatoptions = 'jcroqlnt'                    -- Control auto-formatting options
opt.grepformat = '%f:%l:%c:%m'                    -- Format for grep output matching
opt.grepprg = 'rg --vimgrep'                      -- Use ripgrep for :grep command
opt.ignorecase = true                             -- Ignore case in search patterns
opt.infercase = true                              -- Adjust case of match for keyword completion
opt.smartcase = true                              -- Override ignorecase if pattern contains uppercase
opt.autowrite = true                              -- Auto save before commands like :next and :make
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = 'unnamedplus'                       -- Sync with system clipboard
opt.completeopt = { 'menu', 'menuone', 'noselect' } -- Options for insert mode completion.
opt.splitright = true                               -- Open vertical splits to the right
opt.splitbelow = true                               -- Open horizontal splits below
opt.splitkeep = 'screen'                            -- Keep text on screen when splitting
opt.spelllang = 'en'                                -- Set spell checking language to US English

-- Search
opt.hlsearch = true  -- Highlight all search matches
opt.incsearch = true -- Show matches as you type

-- Performance
opt.redrawtime = 1500  -- Time in ms spent redrawing the display
opt.timeoutlen = 300   -- Time to wait for mapped sequence to complete (ms)
opt.updatetime = 300   -- Faster completion and swap file writing
opt.undolevels = 10000 -- Maximum number of changes that can be undone

-- Window
opt.scrolloff = 8     -- Minimum number of lines to keep above/below cursor
opt.sidescrolloff = 8 -- Minimum number of columns to keep left/right of cursor

-- Wild menu
opt.wildmode = 'longest:full,full'                    -- Command-line completion mode
opt.wildignore = '*/node_modules/*,*/dist/*,*/.git/*' -- Ignore these patterns in file operations

-- Shell
opt.shell = 'zsh'                                            -- Set default shell for terminal commands

opt.viewoptions:remove 'curdir'                              -- Don't save current directory in view
opt.shortmess:append { s = true, I = true }                  -- Disable startup message.
opt.backspace:append { 'nostop' }                            -- Don't stop backspacing at start of line
opt.diffopt:append { 'algorithm:histogram', 'linematch:60' } -- Better diff algorithm and line matching
