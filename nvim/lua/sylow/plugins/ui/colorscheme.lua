return {
  'rebelot/kanagawa.nvim',
  lazy = false, -- Load the theme immediately
  priority = 1000, -- Ensure it loads first
  config = function()
    -- Default options:
    require('kanagawa').setup({
      compile = false, -- enable compiling the colorscheme
      undercurl = true, -- enable undercurls
      commentStyle = {
        italic = true,
      },
      functionStyle = {
        italic = true,
      },
      keywordStyle = {
        italic = true,
      },
      statementStyle = {
        bold = true,
      },
      typeStyle = {},
      transparent = false, -- do not set background color
      dimInactive = false, -- dim inactive window `:h hl-NormalNC`
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
      colors = { -- add/modify theme and palette colors
        palette = {},
        theme = {
          wave = {},
          lotus = {},
          dragon = {},
          all = {},
        },
      },
      overrides = function(colors) -- add/modify highlights
        return {}
      end,
      theme = 'dragon', -- Load "wave" theme when 'background' option is not set
      background = { -- map the value of 'background' option to a theme
        dark = 'dragon', -- try "dragon" !
        light = 'lotus',
      },
    })

    -- setup must be called before loading
    vim.cmd('colorscheme kanagawa-dragon')
  end,
}

-- return {
--   'EdenEast/nightfox.nvim',
--   --   'bluz71/vim-moonfly-colors',
--   --   name = 'moonfly',
--   --   --   -- 'rebelot/kanagawa.nvim',
--   --   --   -- 'tiagovla/tokyodark.nvim',
--   --   --   -- 'Mofiqul/vscode.nvim',
--   --   --   -- 'ficcdaf/ashen.nvim',
--   lazy = false,
--   opts = {},
--   config = function()
--     vim.cmd [[colorscheme carbonfox]]
--   end,
-- }
