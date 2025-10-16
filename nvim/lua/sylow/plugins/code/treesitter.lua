local utils = require('sylow.utils')

local function setup_treesitter()
  return {
    auto_install = true,
    highlight = {
      enable = true,
      use_languagetree = true,
      disable = function(_, bufnr)
        return utils.is_big_file(bufnr)
      end,
    },
    matchup = {
      enable = true,
      enable_quotes = true,
      disable = function(_, bufnr)
        return utils.is_big_file(bufnr)
      end,
    },
    additional_vim_regex_highlighting = false,
    indent = { enable = true },
    ensure_installed = {
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
      'markdown',
      'markdown_inline',
      'css',
      'html',
      'scss',
      'http',
      'go',
      'terraform',
      'dockerfile',
      'gitignore',
      'bash',
      'json',
      'bicep',
      'xml',
      'sql',
    },
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = { 'BufWrite', 'CursorHold' },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ['ak'] = { query = '@block.outer', desc = 'around block' },
          ['ik'] = { query = '@block.inner', desc = 'inside block' },
          ['ac'] = { query = '@class.outer', desc = 'around class' },
          ['ic'] = { query = '@class.inner', desc = 'inside class' },
          ['a?'] = { query = '@conditional.outer', desc = 'around conditional' },
          ['i?'] = { query = '@conditional.inner', desc = 'inside conditional' },
          ['af'] = { query = '@function.outer', desc = 'around function ' },
          ['if'] = { query = '@function.inner', desc = 'inside function ' },
          ['al'] = { query = '@loop.outer', desc = 'around loop' },
          ['il'] = { query = '@loop.inner', desc = 'inside loop' },
          ['aa'] = { query = '@parameter.outer', desc = 'around argument' },
          ['ia'] = { query = '@parameter.inner', desc = 'inside argument' },
        },
      },
      move = {
        enable = true,
        set_jumps = true,
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
      },
      swap = {
        enable = true,
        swap_next = {
          ['>K'] = { query = '@block.outer', desc = 'Swap next block' },
          ['>F'] = { query = '@function.outer', desc = 'Swap next function' },
          ['>A'] = { query = '@parameter.inner', desc = 'Swap next parameter' },
        },
        swap_previous = {
          ['<K'] = { query = '@block.outer', desc = 'Swap previous block' },
          ['<F'] = { query = '@function.outer', desc = 'Swap previous function' },
          ['<A'] = { query = '@parameter.inner', desc = 'Swap previous parameter' },
        },
      },
    },
  }
end

local function configure_treesitter(_, opts)
  if type(opts.ensure_installed) == 'table' then
    local added = {}
    opts.ensure_installed = vim.tbl_filter(function(lang)
      if added[lang] then
        return false
      end
      added[lang] = true
      return true
    end, opts.ensure_installed)
  end

  require('nvim-treesitter.configs').setup(opts)
end

local function configure_textobjects()
  if utils.is_available('nvim-treesitter') then
    local opts = utils.get_plugin_opts('nvim-treesitter')
    require('nvim-treesitter.configs').setup({ textobjects = opts.textobjects })
  end

  local move = require('nvim-treesitter.textobjects.move')
  local configs = require('nvim-treesitter.configs')

  for name, fn in pairs(move) do
    if name:find('goto') == 1 then
      move[name] = function(query, ...)
        if vim.wo.diff then
          local config = configs.get_module('textobjects.move')[name]
          for key, q in pairs(config or {}) do
            if query == q and key:find('[%]%[][cC]') then
              vim.cmd('normal! ' .. key)
              return
            end
          end
        end
        return fn(query, ...)
      end
    end
  end
end

local function setup_context_commentstring()
  return {
    enable = true,
    enable_autocmd = false,
  }
end

return {
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = configure_textobjects,
  },
  {
    'windwp/nvim-ts-autotag',
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function(_, opts)
      require('nvim-ts-autotag').setup({})
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = {
      'TSBufDisable',
      'TSBufEnable',
      'TSBufToggle',
      'TSDisable',
      'TSEnable',
      'TSToggle',
      'TSInstall',
      'TSInstallInfo',
      'TSInstallSync',
      'TSModuleInfo',
      'TSUninstall',
      'TSUpdate',
      'TSUpdateSync',
    },
    build = ':TSUpdate',
    opts = function()
      local opts = setup_treesitter()

      -- Merge autotag configuration
      opts.autotag = require('nvim-ts-autotag').setup({})

      -- Merge context commentstring configuration
      opts.context_commentstring = setup_context_commentstring()

      return opts
    end,
    config = configure_treesitter,
  },
}
