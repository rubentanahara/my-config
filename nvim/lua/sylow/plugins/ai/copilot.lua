return {
	-- Copilot
	-- {
	-- 	'github/copilot.vim',
	-- 	lazy = false,
	-- 	cmd = 'Copilot',
	-- 	event = 'InsertEnter',
	-- 	config = function()
	-- 		vim.g.copilot_no_tab_map = true
	-- 		vim.g.copilot_filetypes = {
	-- 			['*'] = true,
	-- 			['markdown'] = false,
	-- 			['text'] = false,
	-- 		}
	-- 		vim.api.nvim_set_keymap('i', '<C-y>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
	-- 	end,
	-- },
	-- Copilot
  {
    'zbirenbaum/copilot.lua',
    lazy = false,
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup()
    end,
  },
  -- Copilot completion source
  {
    'zbirenbaum/copilot-cmp',
    lazy = false,
    config = function()
      require('copilot_cmp').setup()
    end,
  },
}
