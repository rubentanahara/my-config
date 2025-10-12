local lsp_utils = require("sylow.config.lsp")

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        {path = "${3rd}/luv/library", words = {"vim%.uv"}}
      }
    }
  },
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      lsp_utils.apply_default_lsp_settings()
      require('mason').setup{}
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'rust_analyzer' },
        handlers = {
          function(server_name)
            local opts = lsp_utils.apply_user_lsp_settings(server_name)
            require('lspconfig')[server_name].setup(opts)
          end,
        },
      })
    end,
  }
}
