return {
	'mfussenegger/nvim-lint',
	lazy = false,
	event = { 'BufReadPre', 'BufNewFile', 'BufReadPost' },
	config = function()
		local lint = require('lint')
		lint.linters_by_ft = {
			lua = { 'luacheck' },
			javascript = { 'eslint_d' },
			typescript = { 'eslint_d' },
			python = { 'flake8' },
			sql = { 'sqlfluff' },
			rust = { "clippy", "rustc" }, -- Example: using clippy and rustc
		}

		vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
			callback = function()
				require('lint').try_lint()
			end,
		})
	end,
}
