local icons = require('sylow.utils.icons')

return {
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'ramanshrivastava/claude-complete.nvim',
      'fang2hou/blink-copilot',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'enter',
        ['<Tab>'] = {
          function(cmp)
            local copilot = require('copilot.suggestion')
            if copilot.is_visible() then
              copilot.accept()
              return true
            end
          end,
          'snippet_forward',
          'fallback',
        },
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
      },
      snippets = { preset = 'luasnip' },
      appearance = {
        kind_icons = icons.LSP_KINDS,
      },
      completion = {
        documentation = { auto_show = true },
        menu = { border = 'rounded' },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'claude', 'copilot' },
        providers = {
          claude = {
            name = 'Haiku',
            module = 'claude-complete.blink',
            async = true, -- ~2s round-trip: never block menu on us
            timeout_ms = 2000,
            score_offset = 1, -- sit just below your LSP; raise to prioritise
          },
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
          },
        },
      },
      cmdline = {
        sources = function()
          local cmdtype = vim.fn.getcmdtype()
          if cmdtype == '/' or cmdtype == '?' then
            return { 'buffer' }
          end
          if cmdtype == ':' then
            return { 'cmdline', 'path' }
          end
          return {}
        end,
      },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    config = function(_, opts)
      require('blink.cmp').setup(opts)
      vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { link = 'NormalFloat' })
      vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { link = 'FloatBorder' })
      vim.api.nvim_set_hl(0, 'BlinkCmpMenuSelection', { link = 'CursorLine' })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'BlinkCmpMenuOpen',
        callback = function()
          local win = require('blink.cmp.completion.windows.menu').win:get_win()
          local win_config = vim.api.nvim_win_get_config(win)
          win_config.col = win_config.col + 2
          vim.api.nvim_win_set_config(win, win_config)
        end,
      })
    end,
  },
}
