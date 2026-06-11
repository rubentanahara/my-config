require('sylow.core.options')
require('sylow.core.keymaps')
require('sylow.core.autocmds')
require('sylow.core.lazy')

-- -- Workaround for Neovim 0.12.1 markdown treesitter bug
-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = 'markdown',
--   callback = function()
--     vim.treesitter.stop()
--   end,
-- })
