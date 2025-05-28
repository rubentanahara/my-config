return {
  'projekt0n/github-nvim-theme',
  name = 'github-theme',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('github-theme').setup({
    })

    vim.cmd('colorscheme github_dark_default')
  end,
}


-- return {
--   'catppuccin/nvim',
--   lazy = false,
--   priority = 1000,
--   config = function()
--     vim.cmd [[colorscheme catppuccin-mocha]]
--   end,
-- }
-- return {
--   'rebelot/kanagawa.nvim',
--   lazy = false, -- Load the theme immediately
--   priority = 1000, -- Ensure it loads first
--   opts = {},
--   config = function()
--     -- setup must be called before loading
--     vim.cmd('colorscheme kanagawa-dragon')
--   end,
-- }
--
-- return {
--   'EdenEast/nightfox.nvim',
--   --   'bluz71/vim-moonfly-colors',
--   --   name = 'moonfly',
--   --   --   -- 'rebelot/kanagawa.nvim',
--   --   --   -- 'tiagovla/tokyodark.nvim',
--   --   --   -- 'Mofiqul/vscode.nvim',
--   --   --   -- 'ficcdaf/ashen.nvim',
--   lazy = false,
--   opts = {},
--   config = function()
--     vim.cmd [[colorscheme carbonfox]]
--   end,
-- }
