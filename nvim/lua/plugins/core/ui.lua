return { {
  -- Color scheme
  "rebelot/kanagawa.nvim",
  lazy = false,      -- Load the theme immediately
  priority = 1000,   -- Ensure it loads first
  config = function()
    -- Default options:
    require("kanagawa").setup({
      compile = false,        -- enable compiling the colorscheme
      undercurl = true,       -- enable undercurls
      commentStyle = {
        italic = true
      },
      functionStyle = {
        italic = true
      },
      keywordStyle = {
        italic = true
      },
      statementStyle = {
        bold = true
      },
      typeStyle = {},
      transparent = true,          -- do not set background color
      dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
      terminalColors = true,       -- define vim.g.terminal_color_{0,17}
      colors = {                   -- add/modify theme and palette colors
        palette = {},
        theme = {
          wave = {},
          lotus = {},
          dragon = {},
          all = {}
        }
      },
      overrides = function(colors)       -- add/modify highlights
        return {}
      end,
      theme = "dragon",          -- Load "wave" theme when 'background' option is not set
      background = {             -- map the value of 'background' option to a theme
        dark = "dragon",         -- try "dragon" !
        light = "lotus"
      }
    })

    -- setup must be called before loading
    vim.cmd("colorscheme kanagawa")
  end
}, -- vs code like
  {
    "utilyre/barbecue.nvim",
    event = "VeryLazy",
    name = "barbecue",
    version = "*",
    dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" -- optional dependency
    },
    opts = {
      -- configurations go here
    }
  }, {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  keys = { {
    "<leader>e",
    "<cmd>Neotree toggle<cr>",
    desc = "Toggle Explorer"
  }, {
    "\\",
    "<cmd>Neotree reveal<cr>",
    desc = "Reveal File"
  }, {
    "<leader>ngs",
    "<cmd>Neotree float git_status<cr>",
    desc = "Git Status"
  } },
  dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim", {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      require("window-picker").setup({
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          bo = {
            filetype = { "neo-tree", "neo-tree-popup", "notify" },
            buftype = { "terminal", "quickfix" }
          }
        }
      })
    end
  } },
  opts = {
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = {
        enabled = true,
        leave_dirs_open = true
      },
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = { ".DS_Store", "thumbs.db", "node_modules", "__pycache__" }
      }
    },
    window = {
      position = "left",
      width = 35,
      mappings = {
        ["<space>"] = "none",
        ["l"] = "open",
        ["h"] = "close_node"
      }
    },
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander"
      }
    }
  },
  config = function()
    -- If you want icons for diagnostic errors, you'll need to define them somewhere:
    vim.fn.sign_define("DiagnosticSignError", {
      text = " ",
      texthl = "DiagnosticSignError"
    })
    vim.fn.sign_define("DiagnosticSignWarn", {
      text = " ",
      texthl = "DiagnosticSignWarn"
    })
    vim.fn.sign_define("DiagnosticSignInfo", {
      text = " ",
      texthl = "DiagnosticSignInfo"
    })
    vim.fn.sign_define("DiagnosticSignHint", {
      text = "󰌵",
      texthl = "DiagnosticSignHint"
    })

    require("neo-tree").setup({
      close_if_last_window = false,       -- Close Neo-tree if it is the last window left in the tab
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      -- enable_normal_mode_for_inputs = false,                             -- Enable normal mode for input dialogs.
      open_files_do_not_replace_types = { "terminal", "trouble", "qf" },     -- when opening files, do not use windows containing these filetypes or buftypes
      sort_case_insensitive = false,                                         -- used when sorting files and directories in the tree
      sort_function = nil,                                                   -- use a custom function for sorting files and directories in the tree
      -- sort_function = function(a, b)
      --   if a.type == b.type then
      --     return a.path > b.path
      --   else
      --     return a.type > b.type
      --   end
      -- end, -- this sorts files and directories descendantly
      default_component_configs = {
        container = {
          enable_character_fade = true
        },
        indent = {
          indent_size = 2,
          padding = 1,           -- extra padding on left hand side
          -- indent guides
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          -- expander config, needed for nesting files
          with_expanders = nil,           -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander"
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          default = "",
          symlink = "",
          symlink_arrow = "➜",
          -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
          -- then these will never be used.
          highlight = "NeoTreeFileIcon"
        },
        modified = {
          symbol = " ",
          highlight = "NeoTreeModified"
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName"
        },
        git_status = {
          symbols = {
            -- Change type
            added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
            deleted = "✖", -- this can only be used in the git_status source
            renamed = "󰁕", -- this can only be used in the git_status source
            -- Status type
            untracked = "󰅇",
            ignored = "",
            unstaged = "󰄨",
            staged = "󰄲",
            conflict = ""
          }
        },
        -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
        file_size = {
          enabled = true,
          required_width = 64           -- min width of window required to show this column
        },
        type = {
          enabled = true,
          required_width = 122           -- min width of window required to show this column
        },
        last_modified = {
          enabled = true,
          required_width = 88           -- min width of window required to show this column
        },
        created = {
          enabled = true,
          required_width = 110           -- min width of window required to show this column
        },
        symlink_target = {
          enabled = false
        }
      },
      -- A list of functions, each representing a global custom command
      -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
      -- see `:h neo-tree-custom-commands-global`
      commands = {},
      window = {
        width = 50,
        mapping_options = {
          noremap = true,
          nowait = true
        },
        mappings = {
          ["<space>"] = {
            "toggle_node",
            nowait = false             -- disable `nowait` if you have existing combos starting with this char that you want to use
          },
          ["<2-LeftMouse>"] = "open",
          ["<cr>"] = "open",
          ["<esc>"] = "cancel",           -- close preview or floating neo-tree window
          ["P"] = {
            "toggle_preview",
            config = {
              use_float = true
            }
          },
          ["l"] = "open",
          ["S"] = "open_split",
          ["s"] = "open_vsplit",
          ["t"] = "open_tabnew",
          ["w"] = "open_with_window_picker",
          ["C"] = "close_node",
          ["z"] = "close_all_nodes",
          ["a"] = {
            "add",
            -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
            -- some commands may take optional config options, see `:h neo-tree-mappings` for details
            config = {
              show_path = "none"               -- "none", "relative", "absolute"
            }
          },
          ["A"] = "add_directory",           -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy",           -- takes text input for destination, also accepts the optional config.show_path option like "add":
          ["m"] = "move",           -- takes text input for destination, also accepts the optional config.show_path option like "add".
          ["q"] = "close_window",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["<"] = "prev_source",
          [">"] = "next_source",
          ["i"] = "show_file_details"
        }
      },
      nesting_rules = {},
      filesystem = {
        filtered_items = {
          visible = false,           -- when true, they will just be displayed differently than normal items
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,           -- only works on Windows for hidden files/directories
          hide_by_name = { ".DS_Store", "thumbs.db", "node_modules", "__pycache__", ".virtual_documents",
            ".git", ".python-version", ".venv" },
          hide_by_pattern = {           -- uses glob style patterns
            -- "*.meta",
            -- "*/src/*/tsconfig.json",
          },
          always_show = {           -- remains visible even if other settings would normally hide it
            -- ".gitignored",
          },
          never_show = {                      -- remains hidden even if visible is toggled to true, this overrides always_show
            ".DS_Store"                       -- "thumbs.db"
          },
          never_show_by_pattern = {           -- uses glob style patterns
            -- ".null-ls_*",
          }
        },
        follow_current_file = {
          enabled = false,                              -- This will find and focus the file in the active buffer every time
          --               -- the current file is changed while the tree is open.
          leave_dirs_open = false                       -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
        group_empty_dirs = false,                       -- when true, empty folders will be grouped together
        hijack_netrw_behavior = "open_default",         -- netrw disabled, opening a directory opens neo-tree
        -- in whatever position is specified in window.position
        -- "open_current",  -- netrw disabled, opening a directory opens within the
        -- window like netrw would, regardless of window.position
        -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
        use_libuv_file_watcher = false,         -- This will use the OS level file watchers to detect changes
        -- instead of relying on nvim autocmd events.
        window = {
          mappings = {
            ["<bs>"] = "navigate_up",
            ["."] = "set_root",
            ["H"] = "toggle_hidden",
            ["/"] = "fuzzy_finder",
            ["D"] = "fuzzy_finder_directory",
            ["#"] = "fuzzy_sorter",             -- fuzzy sorting using the fzy algorithm
            -- ["D"] = "fuzzy_sorter_directory",
            ["f"] = "filter_on_submit",
            ["<c-x>"] = "clear_filter",
            ["[g"] = "prev_git_modified",
            ["]g"] = "next_git_modified",
            ["o"] = {
              "show_help",
              nowait = false,
              config = {
                title = "Order by",
                prefix_key = "o"
              }
            },
            ["oc"] = {
              "order_by_created",
              nowait = false
            },
            ["od"] = {
              "order_by_diagnostics",
              nowait = false
            },
            ["og"] = {
              "order_by_git_status",
              nowait = false
            },
            ["om"] = {
              "order_by_modified",
              nowait = false
            },
            ["on"] = {
              "order_by_name",
              nowait = false
            },
            ["os"] = {
              "order_by_size",
              nowait = false
            },
            ["ot"] = {
              "order_by_type",
              nowait = false
            }
          },
          fuzzy_finder_mappings = {           -- define keymaps for filter popup window in fuzzy_finder_mode
            ["<down>"] = "move_cursor_down",
            ["<C-n>"] = "move_cursor_down",
            ["<up>"] = "move_cursor_up",
            ["<C-p>"] = "move_cursor_up"
          }
        },

        commands = {}         -- Add a custom command or override a global one using the same function name
      },
      buffers = {
        follow_current_file = {
          enabled = true,                   -- This will find and focus the file in the active buffer every time
          --              -- the current file is changed while the tree is open.
          leave_dirs_open = false           -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
        group_empty_dirs = true,            -- when true, empty folders will be grouped together
        show_unloaded = true,
        window = {
          mappings = {
            ["bd"] = "buffer_delete",
            ["<bs>"] = "navigate_up",
            ["."] = "set_root",
            ["o"] = {
              "show_help",
              nowait = false,
              config = {
                title = "Order by",
                prefix_key = "o"
              }
            },
            ["oc"] = {
              "order_by_created",
              nowait = false
            },
            ["od"] = {
              "order_by_diagnostics",
              nowait = false
            },
            ["om"] = {
              "order_by_modified",
              nowait = false
            },
            ["on"] = {
              "order_by_name",
              nowait = false
            },
            ["os"] = {
              "order_by_size",
              nowait = false
            },
            ["ot"] = {
              "order_by_type",
              nowait = false
            }
          }
        }
      },
      git_status = {
        window = {
          position = "float",
          mappings = {
            ["A"] = "git_add_all",
            ["gu"] = "git_unstage_file",
            ["ga"] = "git_add_file",
            ["gr"] = "git_revert_file",
            ["gc"] = "git_commit",
            ["gp"] = "git_push",
            ["gg"] = "git_commit_and_push",
            ["o"] = {
              "show_help",
              nowait = false,
              config = {
                title = "Order by",
                prefix_key = "o"
              }
            },
            ["oc"] = {
              "order_by_created",
              nowait = false
            },
            ["od"] = {
              "order_by_diagnostics",
              nowait = false
            },
            ["om"] = {
              "order_by_modified",
              nowait = false
            },
            ["on"] = {
              "order_by_name",
              nowait = false
            },
            ["os"] = {
              "order_by_size",
              nowait = false
            },
            ["ot"] = {
              "order_by_type",
              nowait = false
            }
          }
        }
      }
    })

    vim.cmd([[nnoremap \ :Neotree reveal<cr>]])
    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", {
      noremap = true,
      silent = true
    })     -- focus file explorer
    vim.keymap.set("n", "<leader>ngs", ":Neotree float git_status<CR>", {
      noremap = true,
      silent = true
    })     -- open git status window
  end
},         -- Status line
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    requires = {
      "nvim-tree/nvim-web-devicons",
      opt = true
    },
    config = function()
      local mode = {
        "mode",
        fmt = function(str)
          return " " .. str
        end
      }

      local filename = {
        "filename",
        file_status = true,     -- displays file status (readonly status, modified status)
        path = 1                -- 0 = just filename, 1 = relative path, 2 = absolute path
      }

      local hide_in_width = function()
        return vim.fn.winwidth(0) > 100
      end

      local diagnostics = {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        sections = { "error", "warn" },
        symbols = {
          error = " ",
          warn = " ",
          info = " ",
          hint = "󰌵"
        },
        colored = true,
        update_in_insert = false,
        always_visible = false,
        cond = hide_in_width
      }

      local diff = {
        "diff",
        colored = false,
        symbols = {
          added = " ",
          modified = " ",
          removed = " "
        },     -- changes diff symbols
        cond = hide_in_width
      }

      require("lualine").setup({
        options = {
          icons_enabled = true,
          globalstatus = vim.o.laststatus == 3,
          theme = "auto",       -- Set theme based on environment variable
          -- Some useful glyphs:
          -- https://www.nerdfonts.com/cheat-sheet
          --        
          section_separators = {
            left = "",
            right = ""
          },
          component_separators = {
            left = "",
            right = ""
          },
          disabled_filetypes = { "alpha", "neo-tree" },
          always_divide_middle = true
        },
        sections = {
          lualine_a = { mode },
          lualine_b = { "branch" },
          lualine_c = { filename },
          lualine_x = { diagnostics, diff, {
            "encoding",
            cond = hide_in_width
          }, {
            "filetype",
            cond = hide_in_width
          } },
          lualine_y = { {
            "progress",
            separator = " ",
            padding = {
              left = 1,
              right = 0
            }
          }, {
            "location",
            padding = {
              left = 0,
              right = 1
            }
          } },
          lualine_z = { function()
            return " " .. os.date("%R")
          end }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { {
            "filename",
            path = 1
          } },
          lualine_x = { {
            "location",
            padding = 0
          } },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        extensions = { "fugitive", "nvim-tree", "quickfix" }
      })
    end
  }, -- Better UI elements
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline = {
            pattern = "^:",
            icon = "",
            lang = "vim"
          },
          search_down = {
            kind = "search",
            pattern = "^/",
            icon = " ",
            lang = "regex"
          },
          search_up = {
            kind = "search",
            pattern = "^%?",
            icon = " ",
            lang = "regex"
          },
          filter = {
            pattern = "^:%s*!",
            icon = "$",
            lang = "bash"
          },
          lua = {
            pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
            icon = "",
            lang = "lua"
          },
          help = {
            pattern = "^:%s*he?l?p?%s+",
            icon = "󰋖"
          }
        }
      },
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext"
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
        kind_icons = {
          Class = " ",
          Color = " ",
          Constant = " ",
          Constructor = " ",
          Enum = "了 ",
          EnumMember = " ",
          Field = " ",
          File = " ",
          Folder = " ",
          Function = " ",
          Interface = " ",
          Keyword = " ",
          Method = "ƒ ",
          Module = " ",
          Property = " ",
          Snippet = " ",
          Struct = " ",
          Text = " ",
          Unit = " ",
          Value = " ",
          Variable = " "
        }
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true
        },
        hover = {
          enabled = true,
          silent = false,
          view = nil,
          opts = {}
        },
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true,
            luasnip = true,
            throttle = 50
          },
          view = nil,
          opts = {}
        }
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true
      }
    },
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }
  }, -- Better notifications
  {
    "rcarriga/nvim-notify",
    keys = { {
      "<leader>un",
      function()
        require("notify").dismiss({
          silent = true,
          pending = true
        })
      end,
      desc = "Dismiss all Notifications"
    } },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, {
          zindex = 100
        })
      end,
      stages = "fade",
      background_colour = "#000000",
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "✎"
      }
    }
  }, -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "│"
      },
      scope = {
        enabled = true
      },
      exclude = {
        filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "trouble", "lazy", "mason", "notify",
          "toggleterm", "lazyterm" }
      }
    }
  }, -- Active indent guide and indent text objects
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      symbol = "│",
      options = {
        try_as_border = true
      }
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "trouble", "lazy", "mason", "notify",
          "toggleterm", "lazyterm" },
        callback = function()
          vim.b.miniindentscope_disable = true
        end
      })
    end
  }, -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true
  }, -- UI Components
  {
    "MunifTanjim/nui.nvim",
    lazy = true
  }, -- Word highlighting
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" }
      }
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          pcall(vim.keymap.del, "n", "]]", {
            buffer = buffer
          })
          pcall(vim.keymap.del, "n", "[[", {
            buffer = buffer
          })
        end
      })
    end,
    keys = { {
      "]]",
      function()
        require("illuminate").goto_next_reference(false)
      end,
      desc = "Next Reference"
    }, {
      "[[",
      function()
        require("illuminate").goto_prev_reference(false)
      end,
      desc = "Prev Reference"
    } }
  }, -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        spelling = true
      },
      defaults = {
        mode = { "n", "v" },
        ["g"] = {
          name = "+goto"
        },
        ["gz"] = {
          name = "+surround"
        },
        ["]"] = {
          name = "+next"
        },
        ["["] = {
          name = "+prev"
        },
        ["<leader>b"] = {
          name = "+buffer"
        },
        ["<leader>c"] = {
          name = "+code"
        },
        ["<leader>f"] = {
          name = "+file/find"
        },
        ["<leader>g"] = {
          name = "+git"
        },
        ["<leader>h"] = {
          name = "+help"
        },
        ["<leader>n"] = {
          name = "+notes"
        },
        ["<leader>o"] = {
          name = "+open"
        },
        ["<leader>q"] = {
          name = "+quit/session"
        },
        ["<leader>s"] = {
          name = "+search"
        },
        ["<leader>t"] = {
          name = "+test"
        },
        ["<leader>u"] = {
          name = "+ui"
        },
        ["<leader>w"] = {
          name = "+windows"
        },
        ["<leader>x"] = {
          name = "+diagnostics/quickfix"
        }
      }
    }
  }, -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    lazy = false,
    opts = {
      theme = "doom",
      config = {
        header = { "                                   ", "                                   ",
          "                                   ",
          "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
          "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
          "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ",
          "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
          "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
          "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
          "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
          " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
          " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
          "      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ",
          "       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ",
          "                                   " },
        center = { {
          action = "Telescope find_files",
          desc = " Find file",
          icon = " ",
          key = "f"
        }, {
          action = "ene | startinsert",
          desc = " New file",
          icon = " ",
          key = "n"
        }, {
          action = "Telescope oldfiles",
          desc = " Recent files",
          icon = " ",
          key = "r"
        }, {
          action = "Telescope live_grep",
          desc = " Find text",
          icon = " ",
          key = "g"
        }, {
          action = "e $MYVIMRC",
          desc = " Config",
          icon = " ",
          key = "c"
        }, {
          action = "Lazy",
          desc = " Lazy",
          icon = "󰒲 ",
          key = "l"
        }, {
          action = "qa",
          desc = " Quit",
          icon = " ",
          key = "q"
        } },
        footer = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
        end
      }
    },
    dependencies = { { "nvim-tree/nvim-web-devicons" } }
  }, -- bufferline
  {
    'akinsho/bufferline.nvim',
    version = "*",
    event = "VeryLazy",
    dependencies = { 'moll/vim-bbye', 'nvim-tree/nvim-web-devicons' },
    keys = { {
      "<leader>bp",
      "<cmd>BufferLineTogglePin<cr>",
      desc = "Toggle pin"
    }, {
      "<leader>bP",
      "<cmd>BufferLineGroupClose ungrouped<cr>",
      desc = "Delete non-pinned buffers"
    }, {
      "<leader>bo",
      "<cmd>BufferLineCloseOthers<cr>",
      desc = "Delete other buffers"
    }, {
      "<leader>br",
      "<cmd>BufferLineCloseRight<cr>",
      desc = "Delete buffers to the right"
    }, {
      "<leader>bl",
      "<cmd>BufferLineCloseLeft<cr>",
      desc = "Delete buffers to the left"
    }, {
      "<S-h>",
      "<cmd>BufferLineCyclePrev<cr>",
      desc = "Prev buffer"
    }, {
      "<S-l>",
      "<cmd>BufferLineCycleNext<cr>",
      desc = "Next buffer"
    }, {
      "[b",
      "<cmd>BufferLineCyclePrev<cr>",
      desc = "Prev buffer"
    }, {
      "]b",
      "<cmd>BufferLineCycleNext<cr>",
      desc = "Next buffer"
    }, {
      "[B",
      "<cmd>BufferLineMovePrev<cr>",
      desc = "Move buffer prev"
    }, {
      "]B",
      "<cmd>BufferLineMoveNext<cr>",
      desc = "Move buffer next"
    } },
    config = function()
      local bufferline = require("bufferline")
      bufferline.setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end,
          offsets = { {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
            separator = true
          } },
          always_show_bufferline = false,
          separator_style = "thin",
          modified_icon = "●",
          close_icon = "✗",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 30,
          tab_size = 21,
          diagnostics_update_in_insert = false,
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_duplicate_prefix = true,
          persist_buffer_sort = true,
          move_wraps_at_ends = true,
          indicator = {
            icon = "▎",
            style = "icon"
          },
          name_formatter = function(buf)
            return buf.name
          end,
          numbers = function(opts)
            return string.format('%s', opts.ordinal)
          end,
          custom_filter = function(buf_number, _)
            -- Filter out neo-tree buffers from the buffer list
            local ft = vim.bo[buf_number].filetype
            if ft == "neo-tree" then
              return false
            end
            return true
          end
        },
        highlights = {
          buffer_selected = {
            bold = true,
            italic = false
          },
          indicator_selected = {
            fg = {
              attribute = "fg",
              highlight = "Function"
            },
            italic = false
          }
        }
      })

      -- Auto-command to handle Neo-tree buffer visibility
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "neo-tree",
        callback = function(opts)
          vim.schedule(function()
            vim.api.nvim_buf_set_option(opts.buf, "buflisted", false)
          end)
        end
      })
    end
  } }
