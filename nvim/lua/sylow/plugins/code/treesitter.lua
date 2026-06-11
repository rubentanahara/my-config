local utils = require('sylow.utils')

local parsers = {
  'markdown',
  'markdown_inline',
  'kotlin',
  'lua',
  'luadoc',
  'vim',
  'vimdoc',
  'c_sharp',
  'rst',
  'rust',
  'python',
  'javascript',
  'typescript',
  'toml',
  'yaml',
  'css',
  'html',
  'scss',
  'http',
  'go',
  'java',
  'regex',
  'terraform',
  'dockerfile',
  'gitignore',
  'bash',
  'json',
  'bicep',
  'xml',
  'sql',
}

local function setup_highlight_and_indent()
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('sylow_treesitter', { clear = true }),
    callback = function(args)
      local buf = args.buf
      if utils.is_big_file(buf) then
        return
      end
      pcall(vim.treesitter.start, buf)
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

local function configure_textobjects()
  require('nvim-treesitter-textobjects').setup({
    select = { lookahead = true },
    move = { set_jumps = true },
  })

  local select = require('nvim-treesitter-textobjects.select')
  local move = require('nvim-treesitter-textobjects.move')
  local swap = require('nvim-treesitter-textobjects.swap')

  local select_maps = {
    ['ak'] = { query = '@block.outer', desc = 'around block' },
    ['ik'] = { query = '@block.inner', desc = 'inside block' },
    ['ac'] = { query = '@class.outer', desc = 'around class' },
    ['ic'] = { query = '@class.inner', desc = 'inside class' },
    ['a?'] = { query = '@conditional.outer', desc = 'around conditional' },
    ['i?'] = { query = '@conditional.inner', desc = 'inside conditional' },
    ['af'] = { query = '@function.outer', desc = 'around function' },
    ['if'] = { query = '@function.inner', desc = 'inside function' },
    ['al'] = { query = '@loop.outer', desc = 'around loop' },
    ['il'] = { query = '@loop.inner', desc = 'inside loop' },
    ['aa'] = { query = '@parameter.outer', desc = 'around argument' },
    ['ia'] = { query = '@parameter.inner', desc = 'inside argument' },
  }
  for key, map in pairs(select_maps) do
    vim.keymap.set({ 'x', 'o' }, key, function()
      select.select_textobject(map.query, 'textobjects')
    end, { desc = map.desc })
  end

  local move_maps = {
    goto_next_start = {
      [']k'] = { query = '@block.outer', desc = 'Next block start' },
      [']f'] = { query = '@function.outer', desc = 'Next function start' },
      [']a'] = { query = '@parameter.inner', desc = 'Next parameter start' },
    },
    goto_next_end = {
      [']K'] = { query = '@block.outer', desc = 'Next block end' },
      [']F'] = { query = '@function.outer', desc = 'Next function end' },
      [']A'] = { query = '@parameter.inner', desc = 'Next parameter end' },
    },
    goto_previous_start = {
      ['[k'] = { query = '@block.outer', desc = 'Previous block start' },
      ['[f'] = { query = '@function.outer', desc = 'Previous function start' },
      ['[a'] = { query = '@parameter.inner', desc = 'Previous parameter start' },
    },
    goto_previous_end = {
      ['[K'] = { query = '@block.outer', desc = 'Previous block end' },
      ['[F'] = { query = '@function.outer', desc = 'Previous function end' },
      ['[A'] = { query = '@parameter.inner', desc = 'Previous parameter end' },
    },
  }
  for fn_name, maps in pairs(move_maps) do
    for key, map in pairs(maps) do
      vim.keymap.set('n', key, function()
        move[fn_name](map.query, 'textobjects')
      end, { desc = map.desc })
    end
  end

  local swap_next_maps = {
    ['>K'] = { query = '@block.outer', desc = 'Swap next block' },
    ['>F'] = { query = '@function.outer', desc = 'Swap next function' },
    ['>A'] = { query = '@parameter.inner', desc = 'Swap next parameter' },
  }
  local swap_prev_maps = {
    ['<K'] = { query = '@block.outer', desc = 'Swap previous block' },
    ['<F'] = { query = '@function.outer', desc = 'Swap previous function' },
    ['<A'] = { query = '@parameter.inner', desc = 'Swap previous parameter' },
  }
  for key, map in pairs(swap_next_maps) do
    vim.keymap.set('n', key, function()
      swap.swap_next(map.query)
    end, { desc = map.desc })
  end
  for key, map in pairs(swap_prev_maps) do
    vim.keymap.set('n', key, function()
      swap.swap_previous(map.query)
    end, { desc = map.desc })
  end
end

return {
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = configure_textobjects,
  },
  {
    'windwp/nvim-ts-autotag',
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-ts-autotag').setup({})
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'TSInstall', 'TSInstallInfo', 'TSInstallSync', 'TSUninstall', 'TSUpdate', 'TSUpdateSync' },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install(parsers)
      setup_highlight_and_indent()
    end,
  },
}
