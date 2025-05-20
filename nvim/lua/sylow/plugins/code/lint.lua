return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require('lint')
    lint.linters_by_ft = {
      -- javascript = { 'eslint_d' },
      -- typescript = { 'eslint_d' },
      -- javascriptreact = { 'eslint_d' },
      -- typescriptreact = { 'eslint_d' },
      -- python = { 'ruff' },
      lua = { 'luacheck' },
      -- bash = { 'shellcheck' },
      -- sh = { 'shellcheck' },
      -- markdown = { 'markdownlint' },
      -- yaml = { 'yamllint' },
      -- json = { 'jsonlint' },
      -- html = { 'htmlhint' },
      -- css = { 'stylelint' },
      -- scss = { 'stylelint' },
      -- rust = { 'rustfmt' },
      -- kotlin = { 'ktlint' },
      -- c_sharp = { 'cspell' },
      -- go = { 'golangci-lint' },
    }

    vim.keymap.set('n', '<leader>cl', function()
      lint.try_lint()
    end, { desc = 'Lint current file' })
  end,
}
