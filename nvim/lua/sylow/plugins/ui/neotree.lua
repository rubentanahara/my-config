local utils = require('sylow.utils')
local get_icon = utils.get_icon

return {
  {
    's1n7ax/nvim-window-picker',
    version = '2.*',
    config = function()
      require('window-picker').setup({
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          bo = {
            filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
            buftype = { 'terminal', 'quickfix' },
          },
        },
      })
    end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = false,
    cmd = 'Neotree',
    keys = {
      {
        '<leader>e',
        '<cmd>Neotree toggle<cr>',
        desc = 'Toggle Explorer',
      },
      {
        '\\',
        '<cmd>Neotree reveal<cr>',
        desc = 'Reveal File',
      },
      {
        '<leader>ngs',
        '<cmd>Neotree float git_status<cr>',
        desc = 'Git Status',
      },
    },
    opts = {
      sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
      open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { '.DS_Store', 'thumbs.db', 'node_modules', '__pycache__' },
        },
      },
      window = {
        windblend = 100,
        position = 'left',
        width = 30,
        mappings = {
          ['<space>'] = 'none',
          ['l'] = 'open',
          ['h'] = 'close_node',
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = '',
          expander_expanded = '',
          expander_highlight = 'NeoTreeExpander',
        },
      },
    },
    config = function()
      -- If you want icons for diagnostic errors, you'll need to define them somewhere:
      vim.fn.sign_define('DiagnosticSignError', {
        text = get_icon('DiagnosticError'),
        texthl = 'DiagnosticSignError',
      })
      vim.fn.sign_define('DiagnosticWarn', {
        texthl = 'DiagnosticWarn',
        text = get_icon('DiagnosticWarn'),
      })
      vim.fn.sign_define('DiagnosticInfo', {
        text = get_icon('DiagnosticInfo'),
        texthl = 'DiagnosticInfo',
      })
      vim.fn.sign_define('DiagnosticHint', {
        text = get_icon('DiagnosticHint'),
        texthl = 'DiagnosticHint',
      })

      require('neo-tree').setup({
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        popup_border_style = 'rounded',
        enable_git_status = true,
        enable_diagnostics = true,
        open_files_do_not_replace_types = { 'terminal', 'trouble', 'qf' }, -- when opening files, do not use windows containing these filetypes or buftypes
        sort_case_insensitive = false, -- used when sorting files and directories in the tree
        sort_function = nil, -- use a custom function for sorting files and directories in the tree
        window = {
          width = 30,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          mappings = {
            ['<space>'] = {
              'toggle_node',
              nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
            },
            ['<2-LeftMouse>'] = 'open',
            ['<cr>'] = 'open',
            ['<esc>'] = 'cancel', -- close preview or floating neo-tree window
            ['P'] = {
              'toggle_preview',
              config = {
                use_float = true,
              },
            },
            ['l'] = 'open',
            ['S'] = 'open_split',
            ['s'] = 'open_vsplit',
            ['t'] = 'open_tabnew',
            ['w'] = 'open_with_window_picker',
            ['C'] = 'close_node',
            ['z'] = 'close_all_nodes',
            ['a'] = {
              'add',
              -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
              -- some commands may take optional config options, see `:h neo-tree-mappings` for details
              config = {
                show_path = 'none', -- "none", "relative", "absolute"
              },
            },
            ['A'] = 'add_directory', -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
            ['d'] = 'delete',
            ['r'] = 'rename',
            ['y'] = 'copy_to_clipboard',
            ['x'] = 'cut_to_clipboard',
            ['p'] = 'paste_from_clipboard',
            ['c'] = 'copy', -- takes text input for destination, also accepts the optional config.show_path option like "add":
            ['m'] = 'move', -- takes text input for destination, also accepts the optional config.show_path option like "add".
            ['q'] = 'close_window',
            ['R'] = 'refresh',
            ['?'] = 'show_help',
            ['<'] = 'prev_source',
            ['>'] = 'next_source',
            ['i'] = 'show_file_details',
          },
        },
        default_component_configs = {
          container = {
            enable_character_fade = true,
          },
          indent = {
            indent_size = 2,
            -- indent guides
            with_markers = true,
            indent_marker = get_icon('Indent'),
            last_indent_marker = get_icon('LastIndent'),
            highlight = 'NeoTreeIndentMarker',
            -- expander config, needed for nesting files
            with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = get_icon('FoldClosed'),
            expander_expanded = get_icon('FoldOpened'),
            expander_highlight = 'NeoTreeExpander',
          },
          icon = {
            folder_closed = get_icon('FolderClosed'),
            folder_open = get_icon('FolderOpen'),
            folder_empty = get_icon('FolderEmpty'),
            folder_empty_open = get_icon('FolderEmpty'),
            default = get_icon('DefaultFile'),
            symlink = "",
            symlink_arrow = " ➜ ",
            -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
            -- then these will never be used.
            highlight = 'NeoTreeFileIcon',
          },
          modified = {
            symbol = get_icon('FileModified'),
            highlight = 'NeoTreeModified',
          },
          name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = 'NeoTreeFileName',
          },
          git_status = {
            symbols = {
              -- Change type
              added = get_icon('GitAdd'),
              modified = get_icon('GitChange'),
              deleted = get_icon('GitDelete'),
              renamed = get_icon('GitRenamed'),
              -- Status type
              untracked = get_icon('GitUntracked'),
              ignored = get_icon('GitIgnored'),
              unstaged = get_icon('GitUnstaged'),
              staged = get_icon('GitStaged'),
              conflict = get_icon('GitConflict'),
            },
          },
          -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
          file_size = {
            enabled = true,
            required_width = 60, -- min width of window required to show this column
          },
          type = {
            enabled = true,
            required_width = 122, -- min width of window required to show this column
          },
          last_modified = {
            enabled = true,
            required_width = 80, -- min width of window required to show this column
          },
          created = {
            enabled = true,
            required_width = 110, -- min width of window required to show this column
          },
          symlink_target = {
            enabled = false,
          },
        },
        -- A list of functions, each representing a global custom command
        -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
        -- see `:h neo-tree-custom-commands-global`
        commands = {},
        nesting_rules = {},
        filesystem = {
          filtered_items = {
            visible = false, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_hidden = false, -- only works on Windows for hidden files/directories
            hide_by_name = {
              '.DS_Store',
              'thumbs.db',
              'node_modules',
              '__pycache__',
              '.virtual_documents',
              '.git',
              '.python-version',
              '.venv',
            },
            hide_by_pattern = { -- uses glob style patterns
              -- "*.meta",
              -- "*/src/*/tsconfig.json",
            },
            always_show = { -- remains visible even if other settings would normally hide it
              -- ".gitignored",
            },
            never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
              '.DS_Store', -- "thumbs.db"
            },
            never_show_by_pattern = { -- uses glob style patterns
              -- ".null-ls_*",
            },
          },
          follow_current_file = {
            enabled = true, -- This will find and focus the file in the active buffer every time
            --               -- the current file is changed while the tree is open.
            leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
          group_empty_dirs = false, -- when true, empty folders will be grouped together
          hijack_netrw_behavior = 'open_default', -- netrw disabled, opening a directory opens neo-tree
          -- in whatever position is specified in window.position
          -- "open_current",  -- netrw disabled, opening a directory opens within the
          -- window like netrw would, regardless of window.position
          -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
          use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
          -- instead of relying on nvim autocmd events.
          window = {
            mappings = {
              ['<bs>'] = 'navigate_up',
              ['.'] = 'set_root',
              ['H'] = 'toggle_hidden',
              ['/'] = 'fuzzy_finder',
              ['D'] = 'fuzzy_finder_directory',
              ['#'] = 'fuzzy_sorter', -- fuzzy sorting using the fzy algorithm
              ['f'] = 'filter_on_submit',
              ['<c-x>'] = 'clear_filter',
              ['[g'] = 'prev_git_modified',
              [']g'] = 'next_git_modified',
              ['o'] = {
                'show_help',
                nowait = false,
                config = {
                  title = 'Order by',
                  prefix_key = 'o',
                },
              },
              ['oc'] = {
                'order_by_created',
                nowait = false,
              },
              ['od'] = {
                'order_by_diagnostics',
                nowait = false,
              },
              ['og'] = {
                'order_by_git_status',
                nowait = false,
              },
              ['om'] = {
                'order_by_modified',
                nowait = false,
              },
              ['on'] = {
                'order_by_name',
                nowait = false,
              },
              ['os'] = {
                'order_by_size',
                nowait = false,
              },
              ['ot'] = {
                'order_by_type',
                nowait = false,
              },
            },
            fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
              ['<down>'] = 'move_cursor_down',
              ['<C-j>'] = 'move_cursor_down',
              ['<up>'] = 'move_cursor_up',
              ['<C-k>'] = 'move_cursor_up',
            },
          },

          commands = {}, -- Add a custom command or override a global one using the same function name
        },
        buffers = {
          follow_current_file = {
            enabled = true, -- This will find and focus the file in the active buffer every time
            --              -- the current file is changed while the tree is open.
            leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
          },
          group_empty_dirs = true, -- when true, empty folders will be grouped together
          show_unloaded = true,
          window = {
            mappings = {
              ['bd'] = 'buffer_delete',
              ['<bs>'] = 'navigate_up',
              ['.'] = 'set_root',
              ['o'] = {
                'show_help',
                nowait = false,
                config = {
                  title = 'Order by',
                  prefix_key = 'o',
                },
              },
              ['oc'] = {
                'order_by_created',
                nowait = false,
              },
              ['od'] = {
                'order_by_diagnostics',
                nowait = false,
              },
              ['om'] = {
                'order_by_modified',
                nowait = false,
              },
              ['on'] = {
                'order_by_name',
                nowait = false,
              },
              ['os'] = {
                'order_by_size',
                nowait = false,
              },
              ['ot'] = {
                'order_by_type',
                nowait = false,
              },
            },
          },
        },
        git_status = {
          window = {
            position = 'float',
            mappings = {
              ['A'] = 'git_add_all',
              ['gu'] = 'git_unstage_file',
              ['ga'] = 'git_add_file',
              ['gr'] = 'git_revert_file',
              ['gc'] = 'git_commit',
              ['gp'] = 'git_push',
              ['gg'] = 'git_commit_and_push',
              ['o'] = {
                'show_help',
                nowait = false,
                config = {
                  title = 'Order by',
                  prefix_key = 'o',
                },
              },
              ['oc'] = {
                'order_by_created',
                nowait = false,
              },
              ['od'] = {
                'order_by_diagnostics',
                nowait = false,
              },
              ['om'] = {
                'order_by_modified',
                nowait = false,
              },
              ['on'] = {
                'order_by_name',
                nowait = false,
              },
              ['os'] = {
                'order_by_size',
                nowait = false,
              },
              ['ot'] = {
                'order_by_type',
                nowait = false,
              },
            },
          },
        },
      })

      vim.cmd([[nnoremap \ :Neotree reveal<cr>]])
      vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', {
        noremap = true,
        silent = true,
      }) -- focus file explorer
      vim.keymap.set('n', '<leader>ngs', ':Neotree float git_status<CR>', {
        noremap = true,
        silent = true,
      }) -- open git status window
    end,
  }
}
