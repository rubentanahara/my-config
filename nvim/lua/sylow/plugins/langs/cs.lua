return {
  {
    'Cliffback/netcoredbg-macOS-arm64.nvim',
    dependencies = { 'mfussenegger/nvim-dap' },
  },
  -- {
  --   'GustavEikaas/easy-dotnet.nvim',
  --   ft = { 'cs' },
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'nvim-telescope/telescope.nvim',
  --     'williamboman/mason.nvim',
  --     'williamboman/mason-lspconfig.nvim',
  --     'neovim/nvim-lspconfig',
  --     'mfussenegger/nvim-dap',
  --   },
  --   config = function()
  --     require('easy-dotnet').setup {
  --       background_scanning = true,
  --     }
  --   end,
  -- },
  {
    'seblyng/roslyn.nvim',
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    ft = { 'cs', 'razor' },
    opts = {},
    init = function()
      -- Must run BEFORE plugin/roslyn.lua's `vim.lsp.enable('roslyn')`, which starts
      -- the client the moment the plugin is sourced. Registering these in `config`
      -- is too late: the client would start with the base config and ignore them.
      vim.lsp.config('roslyn', {
        settings = {
          ['csharp|background_analysis'] = {
            -- compute diagnostics for the whole solution, not just open files
            dotnet_analyzer_diagnostics_scope = 'fullSolution',
            dotnet_compiler_diagnostics_scope = 'fullSolution',
          },
        },
        on_attach = function(client, bufnr)
          vim.keymap.set('n', '<leader>cD', function()
            vim.lsp.buf.workspace_diagnostics { client_id = client.id }
          end, { buffer = bufnr, desc = 'Roslyn: pull solution diagnostics' })
        end,
      })

      -- Auto-pull once the solution finishes initializing. roslyn.nvim emits this
      -- User event with data.client_id (lua/roslyn/lsp/handlers.lua).
      vim.api.nvim_create_autocmd('User', {
        pattern = 'RoslynInitialized',
        callback = function(args)
          vim.lsp.buf.workspace_diagnostics { client_id = args.data.client_id }
        end,
      })
    end,
    config = function(_, opts)
      require('roslyn').setup(opts)
    end,
  },
}
