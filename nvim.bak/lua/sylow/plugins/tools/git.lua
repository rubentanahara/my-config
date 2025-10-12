local utils = require('sylow.core.utils')
local get_icon = utils.get_icon

return {
  {
    'tpope/vim-fugitive',
    enabled = vim.fn.executable('git') == 1,
    dependencies = { 'tpope/vim-rhubarb' },
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
}
