return {
  -- GitHub Copilot plugin
  {
    "github/copilot.vim",
    config = function()
      -- Enable Copilot
      vim.cmd([[Copilot enable]])

      -- Key mappings for Copilot Chat
      vim.api.nvim_set_keymap(
        "n",
        "<leader>cp",
        ":CopilotChat<CR>",
        { noremap = true, silent = true, desc = "Open Copilot Chat" }
      )
    end,
  },

  -- px to rem conversion plugin
  {
    "jsongerber/nvim-px-to-rem",
    config = true,
    -- If you need to set some options replace the line above with:
    -- config = function()
    --   require('nvim-px-to-rem').setup()
    -- end,
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    },
  },
  -- JavaScript documentation generator
  {
    "kkoomen/vim-doge",
    run = ":call doge#install()",
  },

  -- Collection of various small independent plugins/modules
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      require("mini.ai").setup({ n_lines = 500 })

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      require("mini.surround").setup()

      -- Simple and easy statusline
      local statusline = require("mini.statusline")
      -- set use_icons to true if you have a Nerd Font
      statusline.setup({ use_icons = vim.g.have_nerd_font })

      -- Configure sections in the statusline
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end

      -- Check out more at: https://github.com/echasnovski/mini.nvim
    end,
  },
}
