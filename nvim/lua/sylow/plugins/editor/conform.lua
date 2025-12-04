return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require('conform')

    conform.setup({
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        kotlin = { 'ktlint' },
        python = { 'black' },
        csharp = { 'csharpier' },
        markdown = { 'mdformat' },
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
