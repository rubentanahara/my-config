return {
  'rebelot/kanagawa.nvim',
  lazy = false, -- Load the theme immediately
  priority = 1000, -- Ensure it loads first
  config = function()
    vim.cmd('colorscheme kanagawa-dragon')
  end,
}
--
-- return {
--   "folke/tokyonight.nvim",
--   lazy = false,
--   priority = 1000,
--   opts = {},
--   config = function()
-- 		vim.cmd("colorscheme tokyonight-night")
-- 		-- vim.cmd("hi Normal guibg=NONE ctermbg=NONE") -- Make background transparent
-- 	end,
-- }
