local utils = require('sylow.core.utils')
local get_icon = utils.get_icon

local build_cmd ---@type string?
for _, cmd in ipairs({ 'make', 'cmake', 'gmake' }) do
  if vim.fn.executable(cmd) == 1 then
    build_cmd = cmd
    break
  end
end

return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    version = false,
    dependencies = {
      {
        'debugloop/telescope-undo.nvim',
        cmd = 'Telescope',
      },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = (build_cmd ~= 'cmake') and 'make'
          or 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
        enabled = build_cmd ~= nil,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    keys = {
      {
        '<leader>fh',
        function()
          require('telescope.builtin').help_tags()
        end,
        desc = 'Find Help',
      },
      {
        '<leader>fk',
        function()
          require('telescope.builtin').keymaps()
        end,
        desc = 'Find Keymaps',
      },
      {
        '<leader>ff',
        '<cmd>Telescope find_files<cr>',
        desc = 'Find Files',
      },
      {
        '<leader>fs',
        '<cmd>Telescope builtin<cr>',
        desc = 'Find Select Telescope',
      },
      {
        '<leader>fw',
        '<cmd>Telescope grep_string<cr>',
        desc = 'Find current Word',
      },
      {
        '<leader>fg',
        '<cmd>Telescope live_grep<cr>',
        desc = 'Find by Grep',
      },
      {
        '<leader>fd',
        '<cmd>Telescope diagnostics<cr>',
        desc = 'Find Diagnostics',
      },
      {
        '<leader>fr',
        function()
          require('telescope.builtin').resume()
        end,
        desc = 'Find Resume',
      },
      {
        '<leader>f.',
        '<cmd>Telescope oldfiles<cr>',
        desc = 'Find Recent Files',
      },
      {
        '<leader><leader>',
        '<cmd>Telescope buffers<cr>',
        desc = 'Find existing buffers',
      },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
            winblend = 0,
            previewer = true,
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
              preview_width = 0.50,
            },
            vertical = {
              mirror = false,
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
