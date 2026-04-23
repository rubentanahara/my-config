return {
  "ray-x/go.nvim",
  dependencies = {
    "ray-x/guihua.lua",
    "neovim/nvim-lspconfig",
  },
  ft = { "go", "gomod" },
  event = { "CmdlineEnter" },
  build = ':lua require("go.install").update_all_sync()',
  opts = {
    lsp_codelens = false,
  },
  config = function(_, opts)
    require("go").setup(opts)
    local group = vim.api.nvim_create_augroup("GoFormat", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.go",
      callback = function()
        require("go.format").goimports()
      end,
      group = group,
    })
  end,
}
