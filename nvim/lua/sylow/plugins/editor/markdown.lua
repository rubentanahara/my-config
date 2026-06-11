return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
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
    config = function(_, opts)
      require('markdown-plus').setup(opts)
    end,
  },
}
