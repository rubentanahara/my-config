return {
  {
    'Cliffback/netcoredbg-macOS-arm64.nvim',
    dependencies = { 'mfussenegger/nvim-dap' },
  },
  {
    'GustavEikaas/easy-dotnet.nvim',
    ft = { 'cs' },
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
        background_scanning = true,
      }
    end,
  },
  {
    'seblyng/roslyn.nvim',
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    ft = { 'cs', 'razor' },
    opts = {},
  },
}
