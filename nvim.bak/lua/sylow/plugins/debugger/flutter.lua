-- flutter debugger
return {
	'mfussenegger/nvim-dap',
	dependencies = {
		'nvim-lua/plenary.nvim', -- Required for path operations
	},
	config = function()
		local dap = require('dap')

		-- Use dart-debug-adapter from Mason installation
		local mason_path = vim.fn.stdpath('data') .. '/mason/packages/dart-debug-adapter'

		local dart_adapter = {
			type = "executable",
			command = vim.fn.stdpath("data") .. "/mason/bin/dart-debug-adapter",
			args = { "flutter" }
		}

		-- Set up adapters
		dap.adapters.dart = dart_adapter

		-- Flutter debug configuration
		dap.configurations.dart = {
			{
				type = 'dart',
				request = 'launch',
				name = 'Launch Flutter',
				dartSdkPath = '/Users/rubentanahara/development/flutter/bin/cache/dart-sdk',
				program = '${workspaceFolder}/lib/main.dart', -- Adjust the path if necessary
				cwd = '${workspaceFolder}',
			},
			{
				type = 'dart',
				request = 'attach',
				name = 'Attach to Flutter',
				cwd = '${workspaceFolder}',
			},
		}
	end,
}
