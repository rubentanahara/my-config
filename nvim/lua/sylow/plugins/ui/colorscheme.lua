return {
  'rebelot/kanagawa.nvim',
  lazy = false, -- Load the theme immediately
  priority = 1000, -- Ensure it loads first
  config = function()
    vim.cmd('colorscheme kanagawa-dragon')
  end,
}

