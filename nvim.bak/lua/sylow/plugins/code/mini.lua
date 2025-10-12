local function setup_mini_icons()
  return {
    file = {
      ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
      ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      ['.eslintrc.js'] = { glyph = '󰱺', hl = 'MiniIconsYellow' },
      ['.node-version'] = { glyph = '', hl = 'MiniIconsGreen' },
      ['.prettierrc'] = { glyph = '', hl = 'MiniIconsPurple' },
      ['.yarnrc.yml'] = { glyph = '', hl = 'MiniIconsBlue' },
      ['eslint.config.js'] = { glyph = '󰱺', hl = 'MiniIconsYellow' },
      ['package.json'] = { glyph = '', hl = 'MiniIconsGreen' },
      ['tsconfig.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      ['tsconfig.build.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      ['yarn.lock'] = { glyph = '', hl = 'MiniIconsBlue' },
    },
    filetype = {
      dotenv = { glyph = '', hl = 'MiniIconsYellow' },
    },
  }
end

local function setup_mini_indentscope()
  return {
    options = { border = 'top', try_as_border = true },
    symbol = '▏',
  }
end

local function setup_mini_pairs()
  return {
    skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    skip_ts = { 'string' },
    skip_unbalanced = true,
    markdown = true,
    modes = { insert = true, command = false, terminal = false },
    mappings = {
      ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
      ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
      ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },
      [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
      [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
      ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
      ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
      ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
      ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
    },
  }
end

local function setup_mini_surround()
  return {
    mappings = {
      add = 'gza',
      delete = 'gzd',
      find = 'gzf',
      find_left = 'gzF',
      highlight = 'gzh',
      replace = 'gzr',
      update_n_lines = 'gzn',
    },
  }
end

-- Mini.surround key mappings generator
local function get_surround_keys(_, keys)
  local plugin = require('lazy.core.config').spec.plugins['mini.surround']
  local opts = require('lazy.core.plugin').values(plugin, 'opts', false)
  local mappings = {
    { opts.mappings.add, desc = 'Add surrounding', mode = { 'n', 'v' } },
    { opts.mappings.delete, desc = 'Delete surrounding' },
    { opts.mappings.find, desc = 'Find right surrounding' },
    { opts.mappings.find_left, desc = 'Find left surrounding' },
    { opts.mappings.highlight, desc = 'Highlight surrounding' },
    { opts.mappings.replace, desc = 'Replace surrounding' },
    { opts.mappings.update_n_lines, desc = 'Update `MiniSurround.config.n_lines`' },
  }
  mappings = vim.tbl_filter(function(m)
    return m[1] and #m[1] > 0
  end, mappings)
  return vim.list_extend(mappings, keys)
end

return {
  {
    'echasnovski/mini.icons',
    opts = setup_mini_icons,
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
    config = function(_, opts)
      require('mini.icons').setup(opts)
    end,
  },
  {
    'echasnovski/mini.indentscope',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = setup_mini_indentscope,
  },
  {
    'echasnovski/mini.pairs',
    event = 'VeryLazy',
    opts = setup_mini_pairs,
  },
  {
    'echasnovski/mini.surround',
    keys = get_surround_keys,
    opts = setup_mini_surround,
  },
}
