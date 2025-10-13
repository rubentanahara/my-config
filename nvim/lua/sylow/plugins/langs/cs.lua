return {
  {
    "Cliffback/netcoredbg-macOS-arm64.nvim",
    dependencies = { "mfussenegger/nvim-dap" }
  },
  {
    'GustavEikaas/easy-dotnet.nvim',
    ft = { 'cs', 'fs', 'vb' },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'neovim/nvim-lspconfig',
      'mfussenegger/nvim-dap',
    },
    config = function()
      require('easy-dotnet').setup {
        background_scanning = false,
      }
    end,
  },
  {
    'seblyng/roslyn.nvim',
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    ft = { 'cs', 'razor' },
    opts = {
      -- your configuration comes here; leave empty for default settings
    },
    -- dependencies = {
    --   {
    --     -- By loading as a dependencies, we ensure that we are available to set
    --     -- the handlers for Roslyn.
    --     "tris203/rzls.nvim",
    --     config = true,
    --   },
    -- },
    lazy = false,
    config = function()
      -- require("configs.rzls").configure()
    end,
    init = function()
      -- We add the Razor file types before the plugin loads.
      -- vim.filetype.add({
      --   extension = {
      --     razor = "razor",
      --     cshtml = "razor",
      --   },
      -- })
    end,
  },
  {
    'nvim-neotest/neotest',
    requires = {
      {
        'Issafalcon/neotest-dotnet',
      },
    },
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    'Issafalcon/neotest-dotnet',
    lazy = false,
    dependencies = {
      'nvim-neotest/neotest',
    },
  },
  { 'Hoffs/omnisharp-extended-lsp.nvim', opts = { enable_import_completion = true } },
}
