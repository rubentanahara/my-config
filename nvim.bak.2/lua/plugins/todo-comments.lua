return {
	"folke/todo-comments.nvim",
	event = "VeryLazy",
	dependencies = "nvim-lua/plenary.nvim",
	config = function()
		local todo = require('todo-comments')

		todo.setup {
			keywords = {
				FIX = {
					icon = " ", -- icon used for the sign, and in search results
					color = "error", -- can be a hex color, or a named color (see below)
					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
					-- signs = false, -- configure signs for some keywords individually
				},
				TODO = { icon = " ", color = "info" },
				todo = { icon = " ", color = "info" },
				Todo = { icon = " ", color = "info" },
				HACK = { icon = " ", color = "warning" },
				hack = { icon = " ", color = "warning" },
				Hack = { icon = " ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				warn = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				Warn = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = "⚡️", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				perf = { icon = "⚡️", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				Perf = { icon = "⚡️", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = "📝", color = "hint", alt = { "INFO" } },
				note = { icon = "📝", color = "hint", alt = { "INFO" } },
				Note = { icon = "📝", color = "hint", alt = { "INFO" } },
				TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
				test = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
				Test = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			}
		}
	end
}
-- {
-- 	return {
-- 	"folke/todo-comments.nvim",
-- 	event = "VeryLazy",
-- 	dependencies = "nvim-lua/plenary.nvim",
-- 	config = function()
-- 		require("todo-comments").setup({
-- 			keywords = {
-- 				FIX = {
-- 					icon = " ", -- Bug icon (fix-related)
-- 					color = "error",
-- 					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
-- 				},
-- 				TODO = { icon = " ", color = "info" }, -- Checkmark for general tasks
-- 				HACK = { icon = " ", color = "warning" }, -- Brainstorm for hacks
-- 				WARN = {
-- 					icon = " ", -- Exclamation for warnings
-- 					color = "warning",
-- 					alt = { "WARNING", "XXX" },
-- 				},
-- 				PERF = {
-- 					icon = "󰓅 ", -- Lightning bolt for performance optimizations
-- 					color = "performance",
-- 					alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
-- 				},
-- 				NOTE = {
-- 					icon = " ", -- Notepad icon for notes
-- 					color = "hint",
-- 					alt = { "INFO" },
-- 				},
-- 				TEST = {
-- 					icon = "󰙨 ", -- Timer for test-related tasks
-- 					color = "test",
-- 					alt = { "TESTING", "PASSED", "FAILED" },
-- 				},
-- 			},
-- 		})
-- 	end,
-- }
