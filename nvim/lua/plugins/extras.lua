vim.filetype.add({
  extension = {
    ['http'] = 'http',
  },
})
return {
  {
    'mistweaverco/kulala.nvim',
    ft = 'http',
    keys = {
      { '<leader>R', '', desc = '+Rest', ft = 'http' },
      { '<leader>Rb', "<cmd>lua require('kulala').scratchpad()<cr>", desc = 'Open scratchpad', ft = 'http' },
      { '<leader>Rc', "<cmd>lua require('kulala').copy()<cr>", desc = 'Copy as cURL', ft = 'http' },
      { '<leader>RC', "<cmd>lua require('kulala').from_curl()<cr>", desc = 'Paste from curl', ft = 'http' },
      {
        '<leader>Rg',
        "<cmd>lua require('kulala').download_graphql_schema()<cr>",
        desc = 'Download GraphQL schema',
        ft = 'http',
      },
      { '<leader>Ri', "<cmd>lua require('kulala').inspect()<cr>", desc = 'Inspect current request', ft = 'http' },
      { '<leader>Rn', "<cmd>lua require('kulala').jump_next()<cr>", desc = 'Jump to next request', ft = 'http' },
      { '<leader>Rp', "<cmd>lua require('kulala').jump_prev()<cr>", desc = 'Jump to previous request', ft = 'http' },
      { '<leader>Rq', "<cmd>lua require('kulala').close()<cr>", desc = 'Close window', ft = 'http' },
      { '<leader>Rr', "<cmd>lua require('kulala').replay()<cr>", desc = 'Replay the last request', ft = 'http' },
      { '<leader>Rs', "<cmd>lua require('kulala').run()<cr>", desc = 'Send the request', ft = 'http' },
      { '<leader>RS', "<cmd>lua require('kulala').show_stats()<cr>", desc = 'Show stats', ft = 'http' },
      { '<leader>Rt', "<cmd>lua require('kulala').toggle_view()<cr>", desc = 'Toggle headers/body', ft = 'http' },
    },
    opts = {},
  },
  {
    -- Make sure to set this up properly if you have lazy=true
    'MeanderingProgrammer/render-markdown.nvim',
    opts = {
      file_types = { 'markdown', 'Avante' },
    },
    ft = { 'markdown', 'Avante' },
  },
    -- Enhanced window picker
  {
    "s1n7ax/nvim-window-picker",
    event = "VeryLazy",
    version = "2.*",
    opts = {
      filter_rules = {
        include_current_win = false,
        autoselect_one = true,
        bo = {
          filetype = { "neo-tree", "neo-tree-popup", "notify", "quickfix" },
          buftype = { "terminal" },
        },
      },
      highlights = {
        statusline = {
          focused = {
            fg = "#ededed",
            bg = "#e35e4f",
            bold = true,
          },
          unfocused = {
            fg = "#ededed",
            bg = "#44cc41",
            bold = true,
          },
        },
      },
    },
  },

  -- Enhanced markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_browser = ""
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_page_title = "${name}"
    end,
  },

  -- Color highlighter
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = {
        "*",
        "!lazy",
        "!mason",
      },
      user_default_options = {
        RGB = true,
        RRGGBB = true,
        names = false,
        RRGGBBAA = true,
        AARRGGBB = false,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
        tailwind = true,
        sass = { enable = true, parsers = { "css" } },
        virtualtext = "■",
      },
      buftypes = {
        "*",
        "!prompt",
        "!popup",
      },
    },
  },

  -- Enhanced search highlighting
  {
    'kevinhwang91/nvim-hlslens',
    event = 'VeryLazy',
    opts = {
      calm_down = true,
      nearest_only = true,
    },
    keys = {
      { 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]] },
      { 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]] },
      { '*', [[*<Cmd>lua require('hlslens').start()<CR>]] },
      { '#', [[#<Cmd>lua require('hlslens').start()<CR>]] },
      { 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]] },
      { 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]] },
    },
  },
}
