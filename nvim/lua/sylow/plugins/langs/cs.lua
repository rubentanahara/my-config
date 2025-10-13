return {
  {
    "seblyng/roslyn.nvim",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    ft = { "cs", "razor" },
    opts = {
      -- your configuration comes here; leave empty for default settings
    },
    dependencies = {
      {
        -- By loading as a dependencies, we ensure that we are available to set
        -- the handlers for Roslyn.
        "tris203/rzls.nvim",
        config = true,
      },
    },
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
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "c_sharp" } },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "csharpier", "netcoredbg" } },
  },
  {
    "Issafalcon/neotest-dotnet",
  },
  { "Hoffs/omnisharp-extended-lsp.nvim", opts = { enable_import_completion = true } },
}
