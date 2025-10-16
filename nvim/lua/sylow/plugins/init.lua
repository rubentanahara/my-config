local utils = require('sylow.utils')

return {
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    opts = {
      -- enable_autocmd = false, -- Recommended to disable for efficiency
    },
    config = function(_, opts)
      vim.g.skip_ts_context_commentstring_module = true
      require('ts_context_commentstring').setup(opts)
    end,
  },
  {
    'nvim-lua/plenary.nvim',
  },
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
    cond = function()
      return vim.env.TMUX ~= nil
    end,
    keys = {
      { '<C-h>', '<cmd>TmuxNavigateLeft<cr>', desc = 'Navigate Left' },
      { '<C-j>', '<cmd>TmuxNavigateDown<cr>', desc = 'Navigate Down' },
      { '<C-k>', '<cmd>TmuxNavigateUp<cr>', desc = 'Navigate Up' },
      { '<C-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Navigate Right' },
      { '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>', desc = 'Navigate Previous' },
    },
  },
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    opts = {
      input = {
        enabled = true,
        default_prompt = 'Input: ',
        title_pos = 'left',
        insert_only = true,
        start_in_insert = true,
        relative = 'cursor',
        prefer_width = 40,
        width = nil,
        max_width = { 140, 0.9 },
        min_width = { 20, 0.2 },
        buf_options = {},
        win_options = {
          winblend = 10,
          wrap = false,
        },
      },
      select = {
        enabled = true,
        backend = { 'telescope', 'fzf_lua', 'fzf', 'builtin', 'nui' },
        telescope = {
          layout_config = { width = 0.8, height = 0.8 },
        },
      },
    },
  },
  {
    'nvim-tree/nvim-web-devicons',
    event = 'VeryLazy',
  },

  {
    'folke/ts-comments.nvim',
    event = 'VeryLazy',
    opts = {},
  },
  {
    'folke/zen-mode.nvim',
    event = 'VeryLazy',
    keys = {
      { '<leader>zz', '<cmd>ZenMode<cr>', desc = 'Toggle Zen Mode' },
    },
    opts = {
      window = {
        backdrop = 0.95,
        width = 120,
        height = 1,
        options = {
          signcolumn = 'no',
          number = false,
          relativenumber = false,
          cursorline = false,
          cursorcolumn = false,
          foldcolumn = '0',
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
        },
        twilight = { enabled = true },
        gitsigns = { enabled = false },
        tmux = { enabled = false },
      },
    },
  },

  {
    'SmiteshP/nvim-navic',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = function()
      return {
        separator = utils.get_icon('PathSeparator'),
        highlight = true,
        depth_limit = 5,
        icons = utils.icons.LSP_KINDS,
        lazy_update_context = true,
        safe_output = true,
        click = true,
      }
    end,
  },

  {
    'MunifTanjim/nui.nvim',
    lazy = true,
  },
}
