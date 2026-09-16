return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require('conform')

    local function js_formatter(bufnr)
      local biome_root = vim.fs.find({ 'biome.json', 'biome.jsonc' }, {
        upward = true,
        path = vim.api.nvim_buf_get_name(bufnr),
      })[1]
      return biome_root and { 'biome' } or { 'prettier' }
    end

    conform.setup({
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = js_formatter,
        javascriptreact = js_formatter,
        typescript = js_formatter,
        typescriptreact = js_formatter,
        kotlin = { 'ktlint' },
        python = { 'black' },
        csharp = { 'csharpier' },
        json = { 'jq' },
        yaml = { 'yamlfmt' },
      },
    })

    vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
      conform.format({
        lsp_fallback = true,
        async = true,
        timeout_ms = 1000,
      })
    end, { desc = 'Format file or range (in visual mode)' })
  end,
}
