local utils = require('sylow.core.utils')
local get_icon = utils.get_icon
local utils_lsp = require('sylow.core.utils.lsp')

return {
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup({
        registries = {
          'github:nvim-java/mason-registry',
          'github:mason-org/mason-registry',
        },
        ui = {
          icons = {
            package_installed = get_icon('MasonInstalled'),
            package_uninstalled = get_icon('MasonUninstalled'),
            package_pending = get_icon('MasonPending'),
          },
        },
      })
      require('mason-lspconfig').setup({
        ensure_installed = {
          'lua_ls',
        },
        handlers = {
          function(server_name)
            utils.notify('setting up ' .. server_name)
            utils_lsp.setup(server_name)
          end,
        },
      })
      utils_lsp.apply_default_lsp_settings()
      utils.trigger_event('FileType')
    end,
  },
}
