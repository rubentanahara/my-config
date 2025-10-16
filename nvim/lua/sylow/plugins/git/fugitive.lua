local utils = require('sylow.utils')
return {
  {
    'tpope/vim-rhubarb',
    event = 'BufReadPre',
    cond = function()
      utils.is_git_repo()
    end,
  },
  {
    'tpope/vim-fugitive',
    event = 'VeryLazy',
    cond = function()
      utils.is_git_repo()
    end,
  },
}
