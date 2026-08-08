return {
  -- {
  --   'MeanderingProgrammer/render-markdown.nvim',
  --   ft = 'markdown',
  --   dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
  --   ---@module 'render-markdown'
  --   ---@type render.md.UserConfig
  --   opts = {},
  -- },
  {
    'OXY2DEV/markview.nvim',
    ft = 'markdown',
    opts = {},
  },
  {
    'tadmccorkle/markdown.nvim',
    ft = 'markdown',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
    config = function(_, opts)
      pcall(function()
        require('nvim-treesitter').install({ 'markdown', 'markdown_inline' })
      end)
      require('markdown').setup(opts)
    end,
  },
  {
    'yousefhadder/markdown-plus.nvim',
    ft = 'markdown',
    opts = {},
  },
  {
    'selimacerbas/markdown-preview.nvim',
    dependencies = { 'selimacerbas/live-server.nvim' },
    ft = 'markdown',
    config = function()
      require('markdown_preview').setup({
        -- all optional; sane defaults shown
        instance_mode = 'takeover', -- "takeover" (one tab) or "multi" (tab per instance)
        port = 0, -- 0 = auto (8421 for takeover, OS-assigned for multi)
        open_browser = true,
        default_theme = 'dark', -- "dark" or "light"; initial preview theme
        debounce_ms = 300,
      })

      vim.keymap.set('n', '<leader>mps', '<cmd>MarkdownPreview<cr>', { desc = 'Markdown: Start preview' })
      vim.keymap.set('n', '<leader>mpS', '<cmd>MarkdownPreviewStop<cr>', { desc = 'Markdown: Stop preview' })
      vim.keymap.set('n', '<leader>mpr', '<cmd>MarkdownPreviewRefresh<cr>', { desc = 'Markdown: Refresh preview' })
    end,
  },
}
