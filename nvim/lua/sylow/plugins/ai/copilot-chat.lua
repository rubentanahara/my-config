local prompts = {
	-- Code related prompts
	Explain =
	"Provide a detailed explanation of the following code, including its purpose, logic flow, and any key algorithms or data structures used. Use examples where necessary to clarify complex parts.",
	Review =
	"Conduct a thorough review of the following code. Identify any potential bugs, performance issues, or areas for improvement. Provide specific suggestions for refactoring, optimizing, and adhering to best practices.",
	Tests =
	"Analyze the provided code to understand its functionality and edge cases. Generate a comprehensive set of unit tests that cover all possible scenarios, including normal, boundary, and exceptional cases. Explain the rationale behind each test case.",
	Refactor =
	"Refactor the following code to improve its clarity, readability, and maintainability. Ensure that the refactored code adheres to industry standards and best practices. Preserve the original functionality and explain the changes made.",
	FixCode =
	"Identify and fix any issues in the following code to ensure it works as intended. Provide a detailed explanation of the problems found and the solutions implemented. Include any necessary optimizations or improvements.",
	FixError =
	"Examine the following text to identify and explain any errors in detail. Provide a step-by-step solution to resolve these errors, including any necessary code changes or additional context that might be helpful.",
	BetterNamings =
	"Suggest more descriptive, meaningful, and consistent names for the following variables, functions, and other identifiers. Ensure that the new names adhere to naming conventions and improve the overall readability of the code.",
	Documentation =
	"Create detailed and clear documentation for the following code. Include descriptions of its purpose, functionality, parameters, return values, and usage examples. Use a consistent format and ensure that the documentation is easy to understand.",
	SwaggerApiDocs =
	"Generate comprehensive API documentation for the following API using Swagger. Include detailed descriptions of all endpoints, parameters, request/response formats, and examples. Ensure that the documentation is accurate, up-to-date, and follows Swagger best practices.",
	SwaggerJsDocs =
	"Write detailed JSDoc comments for the following API using Swagger standards. Include descriptions of all endpoints, parameters, request/response formats, and examples. Ensure that the JSDoc comments are clear, accurate, and adhere to Swagger conventions.",
	-- Text related prompts
	Summarize =
	"Summarize the key points of the following text in a concise and coherent manner. Highlight the main ideas, important details, and any conclusions or recommendations. Ensure that the summary is easy to understand and captures the essence of the original text.",
	Spelling =
	"Proofread the following text and correct any grammar, spelling, and punctuation errors. Ensure that the text is clear, coherent, and adheres to standard writing conventions. Provide suggestions for improving sentence structure and readability where necessary.",
	Wording =
	"Enhance the grammar, wording, and overall readability of the following text. Improve sentence structure, clarity, and flow. Ensure that the text is engaging, coherent, and adheres to standard writing conventions. Provide suggestions for making the text more concise and impactful.",
	Concise =
	"Rewrite the following text to make it more concise and to the point. Remove any redundant or unnecessary information while retaining all essential details. Ensure that the revised text is clear, coherent, and easy to understand."
}


return {
	{
		'CopilotC-Nvim/CopilotChat.nvim',
		event = 'VeryLazy',
		branch = 'canary',
		cmd = 'CopilotChat',
		opts = function()
			local user = vim.env.USER or 'User'
			user = user:sub(1, 1):upper() .. user:sub(2)
			return {
				show_help = "no",
				prompts = prompts,
				model = 'claude-3.5-sonnet',
				auto_insert_mode = true,
				question_header = '  ' .. user .. ' ',
				answer_header = '  Copilot ',
				window = {
					width = 0.4,
				},
			}
		end,
		keys = {
			{ '<c-s>',     '<CR>', ft = 'copilot-chat', desc = 'Submit Prompt', remap = true },
			{ '<leader>a', '',     desc = '+ai',        mode = { 'n', 'v' } },
			{
				'<leader>aa',
				function()
					return require('CopilotChat').toggle()
				end,
				desc = 'Toggle (CopilotChat)',
				mode = { 'n', 'v' },
			},
			{
				'<leader>ax',
				function()
					return require('CopilotChat').reset()
				end,
				desc = 'Clear (CopilotChat)',
				mode = { 'n', 'v' },
			},
			{
				'<leader>aq',
				function()
					vim.ui.input({
						prompt = 'Quick Chat: ',
					}, function(input)
						if input ~= '' then
							require('CopilotChat').ask(input)
						end
					end)
				end,
				desc = 'Quick Chat (CopilotChat)',
				mode = { 'n', 'v' },
			},
			{
				'<leader>ap',
				function()
					require('CopilotChat').select_prompt()
				end,
				desc = 'Prompt Actions (CopilotChat)',
				mode = { 'n', 'v' },
			},
		},
		config = function(_, opts)
			local chat = require('CopilotChat')

			vim.api.nvim_create_autocmd('BufEnter', {
				pattern = 'copilot-chat',
				callback = function()
					vim.opt_local.relativenumber = false
					vim.opt_local.number = false
				end,
			})

			chat.setup(opts)
		end,
	},

	-- Edgy integration
	{
		'folke/edgy.nvim',
		optional = true,
		opts = function(_, opts)
			opts.right = opts.right or {}
			table.insert(opts.right, {
				ft = 'copilot-chat',
				title = 'Copilot Chat',
				size = { width = 50 },
			})
		end,
	},
}
