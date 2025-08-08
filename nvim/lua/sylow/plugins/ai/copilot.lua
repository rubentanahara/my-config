return {
	-- Copilot with Tab acceptance
	{
		'github/copilot.vim',
		lazy = false,
		cmd = 'Copilot',
		event = 'InsertEnter',
		config = function()
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_filetypes = {
				['*'] = true,
				['markdown'] = false,
				['text'] = false,
			}

				-- Use <M-]> (Alt+]) to accept Copilot suggestion to avoid conflicts with other completion plugins
			vim.api.nvim_set_keymap('i', '<M-]>',
				[[copilot#Accept("\<CR>")]],
				{ expr = true, silent = true, noremap = true }
			)
		end,
	},
}
