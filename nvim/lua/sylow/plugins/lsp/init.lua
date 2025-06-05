local utils = require('sylow.core.utils')
local get_icon = utils.get_icon
local utils_lsp = require('sylow.core.utils.lsp')

return {
  {
    'williamboman/mason.nvim',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    lazy = false,
    cmd = {
      'Mason',
      'MasonInstall',
      'MasonUninstall',
      'MasonUninstallAll',
      'MasonLog',
      'MasonUpdate',
    },
    build = ':MasonUpdate',
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
      })

      -- import mason-lspconfig
      local mason_lspconfig = require('mason-lspconfig')

      local mason_tool_installer = require('mason-tool-installer')

      mason_lspconfig.setup({
        ensure_installed = {
          'lua_ls', -- lua
          'ts_ls', -- js,js
          'bacon-ls', -- rust
          'omnisharp', -- cs
          'pyright',
        },
        automatic_installation = true,
      })

      mason_tool_installer.setup({
        ensure_installed = {
          -- Formatters
          'stylua', -- lua
          'prettier', -- js,ts
          'csharpier', -- cs
          'rustfmt', -- rust
          'ruff',
          -- Linters
          'luacheck', -- lua
          'eslint_d', -- js,ts
          'semgrep', -- cs
          'bacon', -- rust
          -- Daps
          'js-debug-adapter', -- js,ts
          'netcoredbg', -- cs
          'codelldb', -- rust
        },
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('sylow-lsp-attach', { clear = true }),
        callback = function(ev)
          utils_lsp.apply_default_lsp_settings()
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client ~= nil then
            utils_lsp.apply_user_lsp_mappings(client, ev.buf)
            utils_lsp.apply_user_lsp_settings(client.name)
          end
        end,
      })
    end,
  },
}
