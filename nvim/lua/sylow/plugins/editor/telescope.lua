local utils = require('sylow.utils')
local get_icon = utils.get_icon

local function telescope_builtin()
  return require('telescope.builtin')
end

local function telescope_themes()
  return require('telescope.themes')
end

local keys = {
  {
    '<leader>fh',
    function() telescope_builtin().help_tags() end,
    desc = 'Find Help',
  },
  {
    '<leader>fk',
    function() telescope_builtin().keymaps() end,
    desc = 'Find Keymaps',
  },
  {
    '<leader>ff',
    function() telescope_builtin().find_files() end,
    desc = 'Find Files',
  },
  {
    '<leader>fg',
    function() telescope_builtin().live_grep() end,
    desc = 'Find by Grep',
  },
  {
    '<leader>fd',
    function() telescope_builtin().diagnostics() end,
    desc = 'Find Diagnostics',
  },
  {
    '<leader>fr',
    function() telescope_builtin().resume() end,
    desc = 'Find Resume',
  },
  {
    '<leader>f.',
    function() telescope_builtin().oldfiles() end,
    desc = 'Find Recent Files',
  },
  {
    '<leader>fb',
    function() telescope_builtin().buffers() end,
    desc = 'Find existing buffers',
  },
  {
    '<leader>f,',
    function()
      telescope_builtin().current_buffer_fuzzy_find(
        telescope_themes().get_dropdown({
          winblend = 0,
          previewer = true,
          prompt_title = 'Live Grep in Current Buffer',
        })
      )
    end,
    desc = 'Fuzzily search in current buffer',
  },
  {
    '<leader>f/',
    function()
      telescope_builtin().live_grep({
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      })
    end,
    desc = 'Find in Open Files',
  },
  {
    '<leader>f;',
    function() telescope_builtin().treesitter() end,
    desc = 'Lists Function names, variables, from Treesitter',
  },
}

local function setup_telescope()
  local actions = require('telescope.actions')
  local trouble = require('trouble.sources.telescope')

  local open_with_trouble = function(...)
    return trouble.open(...)
  end

  local function find_command()
    local executables = {
      rg = { 'rg', '--files', '--color', 'never', '-g', '!.git' },
      fd = { 'fd', '--type', 'f', '--color', 'never', '-E', '.git' },
      fdfind = { 'fdfind', '--type', 'f', '--color', 'never', '-E', '.git' },
      find = vim.fn.has('win32') == 0 and { 'find', '.', '-type', 'f' } or nil,
      where = vim.fn.has('win32') == 1 and { 'where', '/r', '.', '*' } or nil,
    }

    for cmd, args in pairs(executables) do
      if vim.fn.executable(cmd) == 1 then
        return args
      end
    end
  end

  local mappings = {
    i = {
      ['<c-t>'] = open_with_trouble,
      ['<a-t>'] = open_with_trouble,
      ['<C-j>'] = actions.move_selection_next,
      ['<C-k>'] = actions.move_selection_previous,
      ['<ESC>'] = actions.close,
      ['<C-c>'] = false,
    },
    n = {
      ['q'] = actions.close,
    },
  }

  return {
    defaults = {
      prompt_prefix = get_icon('PromptPrefix') .. ' ',
      selection_caret = get_icon('PromptPrefix') .. ' ',
      multi_icon = get_icon('PromptPrefix') .. ' ',
      path_display = { 'truncate' },
      entry_prefix = ' ',
      sorting_strategy = 'ascending',
      get_selection_window = function()
        local wins = vim.api.nvim_list_wins()
        table.insert(wins, 1, vim.api.nvim_get_current_win())

        for _, win in ipairs(wins) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == '' then
            return win
          end
        end
        return 0
      end,
      layout_config = {
        horizontal = {
          prompt_position = 'top',
          preview_width = 0.55,
        },
        width = 0.8,
        height = 0.8,
        preview_cutoff = 120,
      },
      mappings = mappings,
    },
    pickers = {
      find_files = {
        file_ignore_patterns = { 'node_modules', '.git', '.venv' },
        hidden = true,
        find_command = find_command,
      },
    },
    extensions = {
      ['ui-select'] = { telescope_themes().get_dropdown() },
    },
  }
end

local function load_extensions(telescope)
  local extensions = {
    -- 'luasnip',
    'notify', 
    'fzf',
    'ui-select',
    -- 'flutter',
    'undo', -- telescope-undo
  }

  for _, ext in ipairs(extensions) do
    local ok, _ = pcall(telescope.load_extension, ext)
    if not ok then
      vim.notify_once(string.format('Telescope extension %s not available', ext), vim.log.levels.WARN)
    end
  end
end

return {
  {
    'debugloop/telescope-undo.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    keys = {
      { '<leader>fu', '<cmd>Telescope undo<cr>', desc = 'Find Undo History' },
    },
    config = function()
      require('telescope').load_extension('undo')
    end,
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('telescope').load_extension('fzf')
    end,
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('telescope').load_extension('ui-select')
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    version = false, -- Use latest version
    keys = keys,
    opts = setup_telescope,
    config = function(_, opts)
      local telescope = require('telescope')
      telescope.setup(opts)
      load_extensions(telescope)
    end,
  },
}
