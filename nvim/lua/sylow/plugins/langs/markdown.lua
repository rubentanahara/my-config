return {
  -- {
  --   'lervag/vimtex',
  --   lazy = false,
  --   init = function()
  --     -- VimTeX configuration goes here, e.g.
  --     vim.g.vimtex_view_method = 'zathura'
  --     vim.g.vimtex_view_forward_search_on_start = false
  --     vim.g.vimtex_compiler_latexmk = {
  --       aux_dir = vim.fn.expand('~') .. '/.texfiles/',
  --       out_dir = vim.fn.expand('~') .. '/.texfiles/',
  --     }
  --   end,
  -- },
  {
    '3rd/image.nvim',
    opts = {
      integrations = {
        markdown = {
          only_render_image_at_cursor = true,
          floating_windows = true,
          resolve_image_path = function(dcument_path, img_path, fallback)
            return vim.fn.exp('~') .. '/vaults/images'
          end,
        },
      },
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
    -- Moved highlight creation out of opts as suggested by plugin maintainer
    -- There was no issue, but it was creating unnecessary noise when ran
    -- :checkhealth render-markdown
    -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/138#issuecomment-2295422741
    opts = {
      bullet = {
        -- Turn on / off list bullet rendering
        enabled = true,
      },
      checkbox = {
        -- Turn on / off checkbox state rendering
        enabled = true,
        -- Determines how icons fill the available space:
        --  inline:  underlying text is concealed resulting in a left aligned icon
        --  overlay: result is left padded with spaces to hide any additional text
        position = 'inline',
        unchecked = {
          -- Replaces '[ ]' of 'task_list_marker_unchecked'
          icon = '   󰄱 ',
          -- Highlight for the unchecked icon
          highlight = 'RenderMarkdownUnchecked',
          -- Highlight for item associated with unchecked checkbox
          scope_highlight = nil,
        },
        checked = {
          -- Replaces '[x]' of 'task_list_marker_checked'
          icon = '   󰱒 ',
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
