vim.loader.enable()

-- Disable built-in netrw (optional, but useful if using a file explorer like nvim-tree)
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- Bootstrap Lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git", "clone", "--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", lazypath
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load core configurations
require("config.options")
require("config.autocmds")
require("config.keymaps")

-- Setup Lazy.nvim
require("lazy").setup({
	spec = { { import = "plugins" } },
	install = { colorscheme = { "nightfox", "habamax" } },
	change_detection = { notify = false },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip", "man", "rplugin", "netrwPlugin",
				"tarPlugin", "tohtml", "tutor", "zipPlugin",
			},
		},
	},
})

