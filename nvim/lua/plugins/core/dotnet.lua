return {
  {
    'MoaidHathot/dotnet.nvim',
    branch = 'dev',
    cmd = "DotnetUI",
    keys = {
      { '<leader>/',   mode = { 'n', 'v' } },
      { '<leader>na',  "<cmd>DotnetUI new_item<cr>",                 desc = '.NET new item',                 silent = true },
      { '<leader>nb',  "<cmd>DotnetUI file bootstrap<cr>",           desc = '.NET bootstrap class',          silent = true },
      { '<leader>nra', "<cmd>DotnetUI project reference add<cr>",    desc = '.NET add project reference',    silent = true },
      { '<leader>nrr', "<cmd>DotnetUI project reference remove<cr>", desc = '.NET remove project reference', silent = true },
      { '<leader>npa', "<cmd>DotnetUI project package add<cr>",      desc = '.NET ada project package',      silent = true },
      { '<leader>npr', "<cmd>DotnetUI project package remove<cr>",   desc = '.NET remove project package',   silent = true },
    },
    opts = {
      project_selection = {
        path_display = 'filename_first',
      }
    },
  },
  -- lazy.nvim
  {
    "GustavEikaas/easy-dotnet.nvim",
    -- 'nvim-telescope/telescope.nvim' or 'ibhagwan/fzf-lua'
    -- are highly recommended for a better experience
    dependencies = { "nvim-lua/plenary.nvim", 'nvim-telescope/telescope.nvim', },
    config = function()
      local function get_secret_path(secret_guid)
        local path = ""
        local home_dir = vim.fn.expand('~')
        if require("easy-dotnet.extensions").isWindows() then
          local secret_path = home_dir ..
              '\\AppData\\Roaming\\Microsoft\\UserSecrets\\' .. secret_guid .. "\\secrets.json"
          path = secret_path
        else
          local secret_path = home_dir .. "/.microsoft/usersecrets/" .. secret_guid .. "/secrets.json"
          path = secret_path
        end
        return path
      end

      local dotnet = require("easy-dotnet")
      -- Options are not required
      dotnet.setup({
        -- Path to the dotnet sdk in macos
        ---@type string
        get_sdk_path = function()
          return "/usr/local/share/dotnet"
        end,
        ---@type TestRunnerOptions
        test_runner = {
          ---@type "split" | "float" | "buf"
          viewmode = "float",
          -- enable_buffer_test_execution = true, --Experimental, run tests directly from buffer
          noBuild = true,
          noRestore = true,
          icons = {
            passed = "",
            skipped = "",
            failed = "",
            success = "",
            reload = "",
            test = "",
            sln = "󰘐",
            project = "󰘐",
            dir = "",
            package = "",
          },
          mappings = {
            run_test_from_buffer = { lhs = "<leader>r", desc = "Run test from buffer" },
            filter_failed_tests = { lhs = "<leader>fe", desc = "Filter failed tests" },
            debug_test = { lhs = "<leader>d", desc = "Debug test" },
            go_to_file = { lhs = "g", desc = "Got to file" },
            run_all = { lhs = "<leader>R", desc = "Run all tests" },
            run = { lhs = "<leader>r", desc = "Run Test" },
            peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
            expand = { lhs = "o", desc = "expand" },
            expand_node = { lhs = "E", desc = "expand node" },
            expand_all = { lhs = "-", desc = "expand all" },
            collapse_all = { lhs = "W", desc = "collapse all" },
            close = { lhs = "q", desc = "close testrunner" },
            refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" }
          },
          --- Optional table of extra args e.g "--blame crash"
          additional_args = {}
        },
        ---@param action "test" | "restore" | "build" | "run"
        terminal = function(path, action, args)
          local commands = {
            run = function()
              return string.format("dotnet run --project %s %s", path, args)
            end,
            test = function()
              return string.format("dotnet test %s %s", path, args)
            end,
            restore = function()
              return string.format("dotnet restore %s %s", path, args)
            end,
            build = function()
              return string.format("dotnet build %s %s", path, args)
            end
          }

          local command = commands[action]() .. "\r"
          vim.cmd("vsplit")
          vim.cmd("term " .. command)
        end,
        secrets = {
          path = get_secret_path
        },
        csproj_mappings = true,
        fsproj_mappings = true,
        auto_bootstrap_namespace = {
          --block_scoped, file_scoped
          type = "block_scoped",
          enabled = true
        },
        -- choose which picker to use with the plugin
        -- possible values are "telescope" | "fzf" | "basic"
        picker = "telescope"
      })

      -- Example command
      vim.api.nvim_create_user_command('Secrets', function()
        dotnet.secrets()
      end, {})

      -- Example keybinding
      vim.keymap.set("n", "<C-p>", function()
        dotnet.run_project()
      end)
    end
  }
}
