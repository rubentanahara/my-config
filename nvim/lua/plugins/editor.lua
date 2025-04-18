local utils = require "base.utils"
local get_icon = utils.get_icon

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
  -- search/replace in multiple files
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
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
  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
    },
    keys = {
      { "<leader>fh",       "<cmd>Telescope help_tags<cr>",   desc = "Find Help" },
      { "<leader>fk",       "<cmd>Telescope keymaps<cr>",     desc = "Find Keymaps" },
      { "<leader>ff",       "<cmd>Telescope find_files<cr>",  desc = "Find Files" },
      { "<leader>fs",       "<cmd>Telescope builtin<cr>",     desc = "Find Select Telescope" },
      { "<leader>fw",       "<cmd>Telescope grep_string<cr>", desc = "Find current Word" },
      { "<leader>fg",       "<cmd>Telescope live_grep<cr>",   desc = "Find by Grep" },
      { "<leader>fd",       "<cmd>Telescope diagnostics<cr>", desc = "Find Diagnostics" },
      { "<leader>fr",       "<cmd>Telescope resume<cr>",      desc = "Find Resume" },
      { "<leader>f.",       "<cmd>Telescope oldfiles<cr>",    desc = "Find Recent Files" },
      { "<leader><leader>", "<cmd>Telescope buffers<cr>",     desc = "Find existing buffers" },
      {
        "<leader>/",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 0,
            previewer = true,
          }))
        end,
        desc = "Fuzzily search in current buffer",
      },
      {
        "<leader>f/",
        function()
          require("telescope.builtin").live_grep({
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
          })
        end,
        desc = "Find in Open Files",
      },
    },
    opts = function()
      local actions = require("telescope.actions")
      local theme = require("telescope.themes")
      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<C-l>"] = actions.select_default,
              ["<C-s>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
            },
            n = {
              ["q"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            file_ignore_patterns = { "node_modules", ".git", ".venv" },
            hidden = true,
          },
          git_files = { theme = "dropdown" },
          buffers = { theme = "dropdown" },
        },
        extensions = {
          ["ui-select"] = {
            theme.get_dropdown(),
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },
  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        spelling = true,
      },
      spec = {
        {
          mode = { "n", "v" },
          {
            "<leader>b",
            group = "buffer",
            icon = { icon = get_icon("ArrowRight"), color = "blue" },
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>dp", group = "profiler" },
          { "<leader>f", group = "file/find" },
          { "<leader>h", group = "harpoon" },
          { "<leader>g", group = "git" },
          { "<leader>r", group = "replace", icon = { icon = "", color = "yellow" } },
          {
            "<leader>l",
            group = "lazy",
            icon = {
              icon = get_icon("Lazy"),
            }
          },
          { "<leader>p", group = "toggle_preview", icon = { icon = "", color = "purple" } },
          { "<leader>m", group = "markdown", icon = { icon = " ", color = "yellow" } },
          { "<leader>n", group = "dotnet_actions", icon = { icon = "", color = "purple" } },
          { "<leader>q", group = "quit" },
          { "<leader>s", group = "session", icon = { icon = " ", color = "blue" } },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
        },
      },
    }
  },
  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghr", gs.reset_hunk, "Reset Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  -- Better diagnostics list and others
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    lazy = "VeryLazy",
    opts = {
      modes = {
       lsp = {
          win = { position = "right" },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)" },
      { "<leader>cS", "<cmd>Trouble lsp toggle<cr>",                      desc = "LSP references/definitions/... (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List (Trouble)" },
      {
        "[q",
        function()
          local trouble = require("trouble")
          if trouble.is_open() then
            trouble.prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Previous Trouble/Quickfix Item",
      },
      {
        "]q",
        function()
          local trouble = require("trouble")
          if trouble.is_open() then
            trouble.next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Next Trouble/Quickfix Item",
      },
    },
  },
  -- Todo comments
  -- TODO:
  -- INFO:
  -- BUG:
  -- WARN:
  -- TESTING:
  -- PERFORMANCE:
  -- OPTIMIZE:
  -- FIXME:
  -- NOTE:
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    keys = {
     { "<leader>xt", "<cmd>TodoTrouble<cr>",                              desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTelescope<cr>",                            desc = "Todo" },
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    },
  },
}
