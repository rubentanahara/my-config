return {
  {
    lazy = false,
    '3rd/diagram.nvim',
    dependencies = {
      { '3rd/image.nvim', opts = {} }, -- you'd probably want to configure image.nvim manually instead of doing this
    },
    opts = { -- you can just pass {}, defaults below
      events = {
        -- render_buffer = { 'InsertLeave', 'BufWinEnter', 'TextChanged' },
        render_buffer = {},
        clear_buffer = { 'BufLeave' },
      },
      renderer_options = {
        mermaid = {
          background = nil, -- nil | "transparent" | "white" | "#hex"
          theme = 'dark', -- nil | "default" | "dark" | "forest" | "neutral"
          scale = 4, -- nil | 1 (default) | 2  | 3 | ...
          width = 800, -- nil | 800 | 400 | ...
          height = 600, -- nil | 600 | 300 | ...
          cli_args = nil, -- nil | { "--no-sandbox" } | { "-p", "/path/to/puppeteer" } | ...
        },
        plantuml = {
          charset = nil,
          -- cli_args = { '-Djava.awt.headless=true' },
        },
        d2 = {
          theme_id = nil,
          dark_theme_id = nil,
          scale = nil,
          layout = nil,
          sketch = nil,
          cli_args = nil, -- nil | { "--pad", "0" } | ...
        },
        gnuplot = {
          size = nil, -- nil | "800,600" | ...
          font = nil, -- nil | "Arial,12" | ...
          theme = 'dark', -- nil | "light" | "dark" | custom theme string
          cli_args = nil, -- nil | { "-p" } | { "-c", "config.plt" } | ...
        },
      },
    },
  },
  -- {
  --   'lervag/vimtex',
  --   lazy = false, -- we don't want to lazy load VimTeX
  --   -- tag = "v2.15", -- uncomment to pin to a specific release
  --   init = function()
  --     -- VimTeX configuration
  --     vim.g.vimtex_view_method = 'skim' -- macOS PDF viewer
  --     vim.g.vimtex_compiler_method = 'latexmk'
  --
  --     -- Try multiple potential paths for latexmk
  --     local latexmk_paths = {
  --       '/usr/local/texlive/2024/bin/x86_64-darwin/latexmk',
  --       '/usr/local/bin/latexmk',
  --       '/opt/homebrew/bin/latexmk',
  --     }
  --
  --     for _, path in ipairs(latexmk_paths) do
  --       if vim.fn.executable(path) == 1 then
  --         vim.g.vimtex_compiler_method_executable = path
  --         break
  --       end
  --     end
  --   end,
  -- },
  {
    'jbyuki/nabla.nvim',
    dependencies = {
      'nvim-neo-tree/neo-tree.nvim',
      'williamboman/mason.nvim',
    },
    lazy = false,

    config = function() end,

    keys = function()
      return {
        {
          '<leader>y',
          ':lua require("nabla").popup()<cr>',
          desc = 'NablaPopUp',
        },
      }
    end,
  },
  {
    '3rd/image.nvim',
    event = 'VeryLazy',
    opts = {
      -- backend = 'kitty',
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { 'markdown', 'vimwiki' }, -- markdown extensions (ie. quarto) can go here
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      kitty_method = 'normal',
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    main = 'render-markdown',
    ft = 'markdown',
    dependencies = {
      'echasnovski/mini.nvim',
      'nvim-treesitter/nvim-treesitter',
      -- 'nvim-tree/nvim-web-devicons',
    },
    enabled = true,
    opts = {
      bullet = {
        enabled = true,
      },
      checkbox = {
        enabled = true,
        -- Determines how icons fill the available space:
        --  inline:  underlying text is concealed resulting in a left aligned icon
        --  overlay: result is left padded with spaces to hide any additional text
        position = 'inline',
        unchecked = {
          -- Replaces '[ ]' of 'task_list_marker_unchecked'
          icon = ' 󰄱 ',
          -- Highlight for the unchecked icon
          highlight = 'RenderMarkdownUnchecked',
          -- Highlight for item associated with unchecked checkbox
          scope_highlight = nil,
        },
        checked = {
          -- Replaces '[x]' of 'task_list_marker_checked'
          icon = ' 󰱒 ',
          -- Highlight for the checked icon
          highlight = 'RenderMarkdownChecked',
          -- Highlight for item associated with checked checkbox
          scope_highlight = nil,
        },
      },
      html = {
        -- Turn on / off all HTML rendering
        enabled = true,
        comment = {
          -- Turn on / off HTML comment concealing
          conceal = false,
        },
      },
      -- Add custom icons lamw26wmal
      link = {
        image = vim.g.neovim_mode == 'skitty' and '' or '󰥶 ',
        custom = {
          youtu = { pattern = 'youtu%.be', icon = '󰗃 ' },
        },
      },
      heading = {
        sign = false,
        icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
        backgrounds = {
          'Headline1Bg',
          'Headline2Bg',
          'Headline3Bg',
          'Headline4Bg',
          'Headline5Bg',
          'Headline6Bg',
        },
        foregrounds = {
          'Headline1Fg',
          'Headline2Fg',
          'Headline3Fg',
          'Headline4Fg',
          'Headline5Fg',
          'Headline6Fg',
        },
      },
    },
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
    keys = {
      {
        '<leader>mp',
        ft = 'markdown',
        '<cmd>MarkdownPreviewToggle<cr>',
        desc = 'Markdown Preview',
      },
    },
  },
}
