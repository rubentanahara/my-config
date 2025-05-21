local utils = require('sylow.core.utils')
local get_icon = utils.get_icon

return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    priority = 1000,
    version = false,
    dependencies = {
      {
        'debugloop/telescope-undo.nvim',
        cmd = 'Telescope',
      },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    keys = {
      {
        '<leader>fh',
        function()
          local builtin = require('telescope.builtin')
          builtin.help_tags()
        end,
        desc = 'Find Help',
      },
      {
        '<leader>fk',
        function()
          local builtin = require('telescope.builtin')
          builtin.keymaps()
        end,
        desc = 'Find Keymaps',
      },
      {
        '<leader>ff',
        function()
          local builtin = require('telescope.builtin')
          builtin.find_files({
            no_ignore = false,
            hidden = true,
          })
        end,
        desc = 'Find Files',
      },
      {
        '<leader>fg',
        function()
          local builtin = require('telescope.builtin')
          builtin.live_grep()
        end,
        desc = 'Find by Grep',
      },
      {
        '<leader>fd',
        function()
          local builtin = require('telescope.builtin')
          builtin.diagnostics()
        end,
        desc = 'Find Diagnostics',
      },
      {
        '<leader>fr',
        function()
          local builtin = require('telescope.builtin')
          builtin.resume()
        end,
        desc = 'Find Resume',
      },
      {
        '<leader>f.',
        function()
          local builtin = require('telescope.builtin')
          builtin.oldfiles()
        end,
        desc = 'Find Recent Files',
      },
      {
        '<leader>fb',
        function()
          local builtin = require('telescope.builtin')
          builtin.buffers()
        end,
        desc = 'Find existing buffers',
      },
      {
        '<leader>f,',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
            winblend = 0,
            previewer = true,
            prompt_title = 'Live Grep in Curent Buffer',
          }))
        end,
        desc = 'Fuzzily search in current buffer',
      },
      {
        '<leader>f/',
        function()
          require('telescope.builtin').live_grep({
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          })
        end,
        desc = 'Find in Open Files',
      },
      {
        '<leader>f;',
        function()
          local builtin = require('telescope.builtin')
          builtin.treesitter()
        end,
        desc = 'Lists Function names, variables, from Treesitter',
      },
    },
    opts = function()
      local actions = require('telescope.actions')
      local theme = require('telescope.themes')

      local open_with_trouble = function(...)
        return require('trouble.sources.telescope').open(...)
      end
      local function find_command()
        if 1 == vim.fn.executable('rg') then
          return { 'rg', '--files', '--color', 'never', '-g', '!.git' }
        elseif 1 == vim.fn.executable('fd') then
          return { 'fd', '--type', 'f', '--color', 'never', '-E', '.git' }
        elseif 1 == vim.fn.executable('fdfind') then
          return { 'fdfind', '--type', 'f', '--color', 'never', '-E', '.git' }
        elseif 1 == vim.fn.executable('find') and vim.fn.has('win32') == 0 then
          return { 'find', '.', '-type', 'f' }
        elseif 1 == vim.fn.executable('where') then
          return { 'where', '/r', '.', '*' }
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
          -- open files in the first window that is an actual file.
          -- use the current window if no other window is available.
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
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = mappings,
        },
        pickers = {
          find_files = {
            theme = 'dropdown',
            file_ignore_patterns = { 'node_modules', '.git', '.venv' },
            hidden = true,
            find_command = find_command,
          },
          git_files = {
            theme = 'dropdown',
          },
          buffers = {
            theme = 'dropdown',
          },
        },
        extensions = {
          ['ui-select'] = { theme.get_dropdown() },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require('telescope')

      telescope.setup(opts)
      telescope.load_extension('luasnip')
      telescope.load_extension('aerial')
      telescope.load_extension('notify')
      telescope.load_extension('fzf')
      telescope.load_extension('ui-select')
    end,
  },
}
