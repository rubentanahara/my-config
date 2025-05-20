return -- Seamless navigation between tmux panes and vim splits
{
  'szw/vim-maximizer',
  keys = {
    { '<leader>sm', '<cmd>MaximizerToggle<CR>', desc = 'Maximize/minimize a split' },
  },
}
