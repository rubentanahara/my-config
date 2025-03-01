return {
  -- Seamless navigation between tmux panes and vim splits
  {
    "christoomey/vim-tmux-navigator",
    event = "VeryLazy",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>",  "<cmd>TmuxNavigateLeft<cr>",     desc = "Navigate Left" },
      { "<c-j>",  "<cmd>TmuxNavigateDown<cr>",     desc = "Navigate Down" },
      { "<c-k>",  "<cmd>TmuxNavigateUp<cr>",       desc = "Navigate Up" },
      { "<c-l>",  "<cmd>TmuxNavigateRight<cr>",    desc = "Navigate Right" },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate Previous" },
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = "GrugFar",
    keys = {
      {
        "<leader>rR",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace",
      },
    },
  },
  -- Session management
  {
    "rmagatti/auto-session",
    lazy = false, -- Load the plugin at startup
    config = function()
      -- Configure auto-session with custom options
      require("auto-session").setup({
        -- Directories to suppress session creation
        suppressed_dirs = {
          "~/Desktop",
          "~/Downloads",
          "tmp",
          "/",
          "~",
        },
        -- Root directory where sessions will be stored
        root_dir = vim.fn.stdpath("data") .. "/sessions/",
        -- Enable/disable auto-saving sessions on exit
        auto_save = {
          enabled = true,   -- Enable auto-saving sessions
          allow_dirs = nil, -- Allow auto-saving in specific directories (optional)
          exclude_dirs = {  -- Exclude specific directories from auto-saving
            "~/Desktop",
            "~/Downloads",
          },
        },
        -- Enable/disable auto-restoring sessions on startup
        auto_restore = {
          enabled = true,   -- Enable auto-restoring sessions
          allow_dirs = nil, -- Allow auto-restoring in specific directories (optional)
          exclude_dirs = {  -- Exclude specific directories from auto-restoring
            "~/Public",
          },
        },
        -- Automatically create new session files
        auto_create = true,    -- Enable auto-creating sessions
        -- Include git branch name in session name
        use_git_branch = true, -- Enable including git branch name
        -- Automatically detect if Lazy.nvim is being used
        lazy_support = true,   -- Enable Lazy.nvim support
        -- Close windows that aren't backed by normal files before auto-saving
        close_unsupported_windows = true,
        -- Handle directory changes by saving and restoring sessions
        cwd_change_handling = {
          enabled = true,                  -- Enable handling of directory changes
          pre_cwd_changed_cmds = {         -- Commands to execute before changing directory
            "tabdo NERDTreeClose",         -- Close NERDTree before saving session
          },
          post_cwd_changed_cmds = {        -- Commands to execute after changing directory
            function()
              require("lualine").refresh() -- Refresh lualine status line
            end,
          },
        },
        -- Hooks for custom actions during session management
        hooks = {
          pre_save = function() -- Function to execute before saving a session
            -- Example: Close specific buffers or perform other actions
            vim.cmd("wq")
          end,
          post_restore = function() -- Function to execute after restoring a session
            -- Example: Reopen specific buffers or perform other actions
            vim.cmd("e!")
          end,
        },
        -- Additional session_lens configuration for session management UI
        session_lens = {
          load_on_setup = true, -- Initialize Session Lens on startup
          previewer = false,    -- Enable file preview in Session Lens
          theme_conf = {
            border = true,      -- Enable border for Session Lens window
          },
          mappings = {
            -- Define key mappings for Session Lens
            delete_session = { "i", "<C-D>" },    -- Delete session with Ctrl+D in insert mode
            alternate_session = { "i", "<C-S>" }, -- Switch to alternate session with Ctrl+S in insert mode
            copy_session = { "i", "<C-Y>" },      -- Copy session with Ctrl+Y in insert mode
          },
        },
        -- Configuration for bypassing auto-save for specific filetypes
        bypass_save_filetypes = { "alpha", "dashboard" }, -- Filetypes to bypass auto-save
      })

      -- Key mappings for session management
      -- List all sessions using Telescope
      vim.keymap.set("n", "<leader>ss", "<cmd>SessionSearch<CR>", {
        silent = true,
        noremap = true,
        desc = "List Sessions",
      })

      -- Save the current session
      vim.keymap.set("n", "<leader>sa", "<cmd>SessionSave<CR>", {
        silent = true,
        noremap = true,
        desc = "Save Session",
      })

      -- Restore the last session
      vim.keymap.set("n", "<leader>sr", "<cmd>SessionRestore<CR>", {
        silent = true,
        noremap = true,
        desc = "Restore Last Session",
      })

      -- Delete a session
      vim.keymap.set("n", "<leader>sd", "<cmd>SessionDelete<CR>", {
        silent = true,
        noremap = true,
        desc = "Delete Session",
      })

      -- Create a new session
      vim.keymap.set("n", "<leader>sc", "<cmd>SessionSave!<CR>", {
        silent = true,
        noremap = true,
        desc = "Create New Session",
      })

      -- Toggle autosave
      vim.keymap.set("n", "<leader>wa", "<cmd>SessionToggleAutoSave<CR>", {
        silent = true,
        noremap = true,
        desc = "Toggle Autosave",
      })
    end,
  }
}
