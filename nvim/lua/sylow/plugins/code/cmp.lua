local utils = require('sylow.core.utils')
local icons = require('sylow.core.icons.icons')

return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-cmdline',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
    },
    opts = function()
      vim.api.nvim_set_hl(0, 'CmpGhostText', {
        link = 'Comment',
        default = true,
      })

      local cmp = require('cmp')
      local luasnip = require('luasnip')

      local border_opts = {
        border = 'rounded',
        winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
      }
      local cmp_window = cmp.config.window.bordered(border_opts)

      local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      return {
        enabled = function()
          local is_prompt = vim.bo.buftype == 'prompt'
          local is_dap_prompt = utils.is_available('cmp-dap')
            and vim.tbl_contains({ 'dap-repl', 'dapui_watches', 'dapui_hover' }, vim.bo.filetype)

          return not (is_prompt and not is_dap_prompt)
        end,
        preselect = cmp.PreselectMode.None,
        sources = cmp.config.sources({
          { name = 'copilot', priority = 1200 },
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip', priority = 750 },
          { name = 'buffer', priority = 500 },
          { name = 'nvim_lua', priority = 400 },
          { name = 'path', priority = 250 },
          { name = 'emoji' },
        }),
        formatting = {
          format = function(entry, item)
            local kind = item.kind
            local kind_icon = icons.LSP_KINDS[kind] or 'X'

            item.kind = string.format('%s', kind_icon)
            item.menu = string.format('(%s)', kind)

            local content = item.abbr
            if #content > 50 then
              item.abbr = string.sub(content, 1, 47) .. '...'
            end

            return item
          end,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        duplicates = {
          nvim_lsp = 1,
          lazydev = 1,
          luasnip = 1,
          cmp_tabnine = 1,
          buffer = 1,
          path = 1,
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        window = {
          completion = cmp_window,
          documentation = cmp_window,
        },
        mapping = {
          ['<PageUp>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select, count = 8 },
          ['<PageDown>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select, count = 8 },
          ['<C-PageUp>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select, count = 16 },
          ['<C-PageDown>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select, count = 16 },
          ['<S-PageUp>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select, count = 16 },
          ['<S-PageDown>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select, count = 16 },

          ['<Up>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
          ['<Down>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
          ['<C-p>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ['<C-n>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
          ['<C-k>'] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ['<C-j>'] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },

          ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ['<C-y>'] = cmp.config.disable,
          ['<C-e>'] = cmp.mapping {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          },
          ['<CR>'] = cmp.mapping.confirm { select = false },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
      }
    end,
  },
}
