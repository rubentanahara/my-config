return {
  'NvChad/nvim-colorizer.lua',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {
    filetypes = {
      '*',
      '!lazy',
      '!mason',
    },
    user_default_options = {
      RGB = true,
      RRGGBB = true,
      names = true,
      RRGGBBAA = true,
      AARRGGBB = false,
      rgb_fn = true,
      hsl_fn = true,
      css = true,
      css_fn = true,
      mode = 'background',
      tailwind = true,
      sass = { enable = true, parsers = { 'css' } },
      virtualtext = '■',
    },
    buftypes = {
      '*',
      '!prompt',
      '!popup',
    },
  },
}
