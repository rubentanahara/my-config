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
      })
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'pylsp',
          'lua_ls',
          'ts_ls',
          'jsonls',
          'rust_analyzer',
          'omnisharp',
        },
      })
      utils_lsp.apply_default_lsp_settings() -- Apply our default lsp settings.
    end,
  },
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {

        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          utils.notify(event.buf)

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('sylow-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('sylow-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'sylow-lsp-highlight', buffer = event2.buf }
              end,
            })
          end
        end,
      })

      require('mason-lspconfig').setup({
        handlers = {
          function(server_name)
            utils_lsp.setup(server_name)
          end,
        },
      })
    end,
  },
}
