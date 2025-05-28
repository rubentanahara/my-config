local utils = require('sylow.core.utils')
local get_icon = utils.get_icon
local utils_lsp = require('sylow.core.utils.lsp')

return {
  {
    'williamboman/mason.nvim',
    cmd = {
      'Mason',
      'MasonInstall',
      'MasonUninstall',
      'MasonUninstallAll',
      'MasonLog',
      'MasonUpdate',
    },
    keys = {
      { '<leader>cmo', ':Mason<CR>', desc = 'Mason' },
      { '<leader>cmi', ':MasonInstall<CR>', desc = 'Mason Install' },
      { '<leader>cmu', ':MasonUninstall<CR>', desc = 'Mason Uninstall' },
      { '<leader>cma', ':MasonUninstallAll<CR>', desc = 'Mason Uninstall All' },
      { '<leader>cml', ':MasonLog<CR>', desc = 'Mason Log' },
      { '<leader>cmU', ':MasonUpdate<CR>', desc = 'Mason Update' },
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
        ensure_installed = {
          'pylsp',
          'lua_ls',
          'ts_ls',
          'jsonls',
          'rust_analyzer',
          'csharp_ls',
          'csharpier',
        },
      })
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
    config = function()
      require('mason-lspconfig').setup({})
    end,
  },
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      utils_lsp.apply_default_lsp_settings()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('sylow-lsp-attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          utils_lsp.apply_user_lsp_mappings(client, event.buf)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            utils_lsp.apply_user_lsp_settings(client.name)
          end
        end,
      })
    end,
  },
}
