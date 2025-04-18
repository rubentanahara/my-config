local utils = require('base.utils')
local get_icon = utils.get_icon

return {
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    opts = {
      theme = 'doom',
      config = {
        header = {
          '                                   ',
          '                                   ',
          '                                   ',
          '   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ',
          '    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ',
          '          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ',
          '           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ',
          '          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ',
          '   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ',
          '  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ',
          ' ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ',
          ' ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ',
          '      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ',
          '       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ',
          '                                   ',
        },
        center = {
          {
            action = 'Telescope find_files',
            desc = ' Find file',
            icon = ' ',
            key = 'f',
          },
          {
            action = 'ene | startinsert',
            desc = ' New file',
            icon = ' ',
            key = 'n',
          },
          {
            action = 'Telescope oldfiles',
            desc = ' Recent files',
            icon = ' ',
            key = 'r',
          },
          {
            action = 'Telescope live_grep',
            desc = ' Find text',
            icon = ' ',
            key = 'g',
          },
          {
            action = 'e $MYVIMRC',
            desc = ' Config',
            icon = ' ',
            key = 'c',
          },
          {
            action = 'Lazy',
            desc = ' Lazy',
            icon = '󰒲 ',
            key = 'l',
          },
          {
            action = 'qa',
            desc = ' Quit',
            icon = ' ',
            key = 'q',
          },
        },
        footer = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
        end,
      },
    },
  },
  -- kanagawa [theme]
  {
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
        transparent = true, -- do not set background color
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
      vim.cmd('colorscheme kanagawa')
    end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
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
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
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
      vim.fn.sign_define('DiagnosticSignWarn', {
        text = get_icon('DiagnosticWarn'),
        texthl = 'DiagnosticSignWarn',
      })
      vim.fn.sign_define('DiagnosticSignInfo', {
        text = get_icon('DiagnosticInfo'),
        texthl = 'DiagnosticSignInfo',
      })
      vim.fn.sign_define('DiagnosticSignHint', {
        text = get_icon('DiagnosticHint'),
        texthl = 'DiagnosticSignHint',
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
            padding = 1, -- extra padding on left hand side
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
            -- symlink = "",
            -- symlink_arrow = " ➜ ",
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
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      routes = {
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
            },
          },
          view = 'mini',
        },
      },
      cmdline = {
        enabled = true,
        format = {
          cmdline = { icon = get_icon('Terminal') },
          search_down = { icon = get_icon('Find') },
          search_up = { icon = get_icon('Find') },
          filter = { icon = '$' },
          lua = { icon = '☾' },
          help = { icon = '?' },
        },
      },
      format = {
        level = {
          icons = {
            error = get_icon('DiagnosticError'),
            warn = get_icon('DiagnosticWarn'),
            info = get_icon('DiagnosticInfo'),
          },
        },
      },
      popupmenu = {
        kind_icons = false,
      },
      inc_rename = {
        cmdline = {
          format = {
            IncRename = { icon = get_icon('MasonPending') },
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>sn", "", desc = "+noice"},
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
      { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
    },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == 'lazy' then vim.cmd([[messages clear]]) end
      require('noice').setup(opts)
    end,
  },
  -- barbecue vs code like style
  {
    'utilyre/barbecue.nvim',
    event = 'VeryLazy',
    name = 'barbecue',
    version = '*',
    opts = {
      -- configurations go here
    },
  },
  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    config = function()
      local mode = {
        'mode',
        fmt = function(str) return get_icon('Vim') .. str end,
      }

      local filename = {
        'filename',
        file_status = true, -- displays file status (readonly status, modified status)
        path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
      }

      local hide_in_width = function() return vim.fn.winwidth(0) > 100 end

      local diagnostics = {
        'diagnostics',
        sources = { 'nvim_diagnostic' },
        sections = { 'error', 'warn', 'info', 'hint' },
        symbols = {
          error = get_icon('DiagnosticError'),
          warn = get_icon('DiagnosticWarn'),
          info = get_icon('DiagnosticInfo'),
          hint = get_icon('DiagnosticHint'),
        },
        colored = true,
        update_in_insert = true,
        cond = hide_in_width,
      }

      local diff = {
        'diff',
        colored = true,
        symbols = {
          added = get_icon('GitAdd'),
          modified = get_icon('GitChange'),
          removed = get_icon('GitDelete'),
        }, -- changes diff symbols
        cond = hide_in_width,
      }

      require('lualine').setup({
        options = {
          icons_enabled = true,
          globalstatus = vim.o.laststatus == 3,
          theme = 'auto',
          section_separators = {
            left = '',
            right = '',
          },
          component_separators = {
            left = '',
            right = '',
          },
          disabled_filetypes = { 'alpha', 'neo-tree' },
          always_divide_middle = true,
        },
        sections = {
          lualine_a = { mode },
          lualine_b = { 'branch' },
          lualine_c = { filename },
          lualine_x = {
            diagnostics,
            diff,
            {
              'encoding',
              cond = hide_in_width,
            },
            {
              'filetype',
              cond = hide_in_width,
            },
          },
          lualine_y = {
            {
              'progress',
              separator = ' ',
              padding = {
                left = 1,
                right = 0,
              },
            },
            {
              'location',
              padding = {
                left = 0,
                right = 1,
              },
            },
          },
          lualine_z = {
            function()
              -- 12-hour format with AM/PM
              return ' ' .. os.date('%I:%M %p')
              -- 24 format
              -- return " " .. os.date("%R")
            end,
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { {
            'filename',
            path = 1,
          } },
          lualine_x = { {
            'location',
            padding = 0,
          } },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        extensions = { 'fugitive', 'nvim-tree', 'quickfix' },
      })
    end,
  },
  -- Smooth scrolling
  {
    'karb94/neoscroll.nvim',
    event = 'VeryLazy',
    opts = {
      mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
    },
  },
  -- Better buffer closing
  {
    'famiu/bufdelete.nvim',
    keys = {
      { '<leader>bd', '<cmd>Bdelete<cr>', desc = 'Delete Buffer' },
      { '<leader>bD', '<cmd>Bdelete!<cr>', desc = 'Delete Buffer (Force)' },
    },
  },
  -- bufferline
  {
    'akinsho/bufferline.nvim',
    version = '*',
    event = 'VeryLazy',
    -- keymaps
    keys = {
      { '<leader>bp', '<cmd>BufferLineTogglePin<cr>', desc = 'Toggle pin' },
      { '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<cr>', desc = 'Delete non-pinned buffers' },
      { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Delete other buffers' },
      { '<leader>br', '<cmd>BufferLineCloseRight<cr>', desc = 'Delete buffers to the right' },
      { '<leader>bl', '<cmd>BufferLineCloseLeft<cr>', desc = 'Delete buffers to the left' },
      { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev buffer' },
      { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next buffer' },
      { '[B', '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer prev' },
      { ']B', '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer next' },
    },
    -- config
    config = function()
      local bufferline = require('bufferline')
      bufferline.setup({
        options = {
          mode = 'buffers',
          diagnostics = 'nvim_lsp',
          diagnostics_indicator = function(count, level)
            local icon = level:match('error') and ' ' or ' '
            return ' ' .. icon .. count
          end,
          offsets = {
            {
              filetype = 'neo-tree',
              text = 'Explorer',
              highlight = 'Directory',
              text_align = 'left',
              separator = true,
            },
          },
          always_show_bufferline = true,
          separator_style = 'thin',
          modified_icon = get_icon('FileModified'),
          close_icon = get_icon('BufferClose'),
          left_trunc_marker = '',
          max_name_length = 30,
          tab_size = 20,
          update_in_insert = true,
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_duplicate_prefix = true,
          persist_buffer_sort = true,
          move_wraps_at_ends = true,
          right_mouse_command = 'bdelete! %d',
          right_trunc_marker = get_icon('ArrowRight'),
          show_tab_indicators = false,
          indicator = {
            style = 'icon',
            icon = get_icon('BufferLineIndicator'),
          },
          name_formatter = function(buf) return buf.name end,
          numbers = function(opts) return string.format('%s', opts.ordinal) end,
          custom_filter = function(buf_number, _)
            -- Filter out neo-tree buffers from the buffer list
            local ft = vim.bo[buf_number].filetype
            if ft == 'neo-tree' then return false end
            return true
          end,
        },
        highlights = {
          fill = {
            fg = { attribute = 'fg', highlight = 'Normal' },
            bg = { attribute = 'bg', highlight = 'StatusLineNC' },
          },
          -- background = {
          --   fg = { attribute = "fg", highlight = "Normal" },
          --   bg = { attribute = "bg", highlight = "StatusLine" },
          -- },
          buffer_visible = {
            fg = { attribute = 'fg', highlight = 'Normal' },
            bg = { attribute = 'bg', highlight = 'Normal' },
          },
          buffer_selected = {
            fg = { attribute = 'fg', highlight = 'Normal' },
            bg = { attribute = 'bg', highlight = 'Normal' },
          },
          -- separator = {
          --   fg = { attribute = "fg", highlight = "Normal" },
          --   bg = { attribute = "bg", highlight = "StatusLine" },
          -- },
          separator_selected = {
            fg = { attribute = 'fg', highlight = 'Special' },
            bg = { attribute = 'bg', highlight = 'Normal' },
          },
          separator_visible = {
            fg = { attribute = 'fg', highlight = 'Normal' },
            bg = { attribute = 'bg', highlight = 'StatusLineNC' },
          },
          -- close_button = {
          --   fg = { attribute = "fg", highlight = "Normal" },
          --   bg = { attribute = "bg", highlight = "StatusLine" },
          -- },
          close_button_selected = {
            fg = { attribute = 'fg', highlight = 'Normal' },
            bg = { attribute = 'bg', highlight = 'Normal' },
          },
          close_button_visible = {
            fg = { attribute = 'fg', highlight = 'Normal' },
            bg = { attribute = 'bg', highlight = 'Normal' },
          },
        },
      })

      -- Auto-command to handle Neo-tree buffer visibility
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'neo-tree',
        callback = function(opts)
          vim.schedule(function() vim.api.nvim_buf_set_option(opts.buf, 'buflisted', false) end)
        end,
      })
    end,
  },
}
