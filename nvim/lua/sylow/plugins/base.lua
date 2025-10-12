local utils = require('sylow.core.utils')

return {
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    opts = {
      enable_autocmd = false, -- Recommended to disable for efficiency
    },
    config = function(_, opts)
      vim.g.skip_ts_context_commentstring_module = true
      require('ts_context_commentstring').setup(opts)
    end,
  },
  { 'tpope/vim-rhubarb' },
  {
    'tpope/vim-fugitive',
    enabled = vim.fn.executable('git') == 1,
    config = function()
      vim.g.fugitive_no_maps = 1
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    enabled = vim.fn.executable('git') == 1,
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
  {
    'nvim-lua/plenary.nvim',
  },
  {
    'christoomey/vim-tmux-navigator',
    event = 'VeryLazy',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd>TmuxNavigateLeft<cr>', desc = 'Navigate Left' },
      { '<c-j>', '<cmd>TmuxNavigateDown<cr>', desc = 'Navigate Down' },
      { '<c-k>', '<cmd>TmuxNavigateUp<cr>', desc = 'Navigate Up' },
      { '<c-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Navigate Right' },
      { '<c-\\>', '<cmd>TmuxNavigatePrevious<cr>', desc = 'Navigate Previous' },
    },
  },
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
  },
  {
    'nvim-tree/nvim-web-devicons',
    event = 'User BaseDeferred',
    opts = {
      override = {
        default_icon = {
          icon = utils.get_icon('DefaultFile'),
        },
      },
      strict = true,
    },
  },
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    'folke/zen-mode.nvim',
    opts = {},
  },
  {
    'SmiteshP/nvim-navic',
    opts = function()
      return {
        separator = utils.icons.PathSeparator,
        highlight = true,
        depth_limit = 5,
        icons = utils.icons.LSP_KINDS,
        lazy_update_context = true,
      }
    end,
  },
  {
    'MunifTanjim/nui.nvim',
  },
    {
    'nvim-flutter/flutter-tools.nvim',
	  dependencies = {
		  'nvim-lua/plenary.nvim',
		  'stevearc/dressing.nvim',     -- optional for vim.ui.select
	  },
	  config = true
	}
}
