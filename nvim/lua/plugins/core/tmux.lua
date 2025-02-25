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

  -- Terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      open_mapping = [[<c-t>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
  },

  -- Session management
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      auto_session_enable_last_session = false,
      auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
      auto_session_enabled = true,
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_use_git_branch = true,
    },
  },
}

