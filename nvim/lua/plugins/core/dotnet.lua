return {
  -- .NET development tools
  {
    lazy = false,
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    ft = { "cs", "fs", "csproj", "fsproj", "sln" },
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

      -- Helper function to find the solution file
      local function find_solution_file()
        local current_file = vim.fn.expand('%:p')
        local current_dir = vim.fn.fnamemodify(current_file, ':h')

        -- Try to find a solution file in the current directory or parent directories
        local solution_file = vim.fn.findfile('*.sln', current_dir .. ';')
        if solution_file ~= '' then
          return solution_file
        end

        return nil
      end

      local dotnet = require("easy-dotnet")
      dotnet.setup({
        test_runner = {
          viewmode = "float",
          enable_buffer_test_execution = true,
          noBuild = false,   -- Changed to false to ensure build before test
          noRestore = false, -- Changed to false to ensure restore before test
          icons = {
            passed = "",
            skipped = "",
            failed = "",
            success = "",
            reload = "",
            test = "",
            sln = "󰘐",
            project = "󰘐",
            dir = "",
            package = "",
          },
          mappings = {
            run_test_from_buffer = { lhs = "<leader>dtt", desc = "run test from buffer" },
            filter_failed_tests = { lhs = "<leader>dtf", desc = "filter failed tests" },
            debug_test = { lhs = "<leader>dtd", desc = "debug test" },
            go_to_file = { lhs = "g", desc = "go to file" },
            run_all = { lhs = "<leader>dta", desc = "run all tests" },
            run = { lhs = "<leader>dtr", desc = "run test" },
            peek_stacktrace = { lhs = "<leader>dts", desc = "peek stacktrace of failed test" },
            expand = { lhs = "o", desc = "expand" },
            expand_node = { lhs = "E", desc = "expand node" },
            expand_all = { lhs = "-", desc = "expand all" },
            collapse_all = { lhs = "W", desc = "collapse all" },
            close = { lhs = "q", desc = "close testrunner" },
            refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" }
          },
        },
        terminal = function(path, action, args)
          local commands = {
            run = function()
              -- Ensure the path is properly quoted and formatted
              local run_path = vim.fn.fnamemodify(path, ':p')
              local dir_path = vim.fn.fnamemodify(run_path, ':h')
              return string.format("cd %s && dotnet run --project \"%s\" %s", dir_path, run_path, args or "")
            end,
            test = function()
              -- Ensure path has proper extension and quotes for spaces
              local test_path = path
              -- Add .csproj extension if not present and not a directory
              if not test_path:match("%.csproj$") and not test_path:match("%.fsproj$") and not vim.fn.isdirectory(test_path) == 1 then
                -- Check if it's a test project
                if test_path:match("Test") or test_path:match("test") then
                  test_path = test_path .. ".csproj"
                end
              end

              -- Ensure the path is properly quoted and formatted
              test_path = vim.fn.fnamemodify(test_path, ':p')
              local dir_path = vim.fn.fnamemodify(test_path, ':h')
              return string.format("cd %s && dotnet test \"%s\" %s", dir_path, test_path, args or "")
            end,
            restore = function()
              -- Ensure the path is properly quoted and formatted
              local restore_path = vim.fn.fnamemodify(path, ':p')
              local dir_path = vim.fn.fnamemodify(restore_path, ':h')
              return string.format("cd %s && dotnet restore \"%s\" %s", dir_path, restore_path, args or "")
            end,
            build = function()
              -- Ensure the path is properly quoted and formatted
              local build_path = vim.fn.fnamemodify(path, ':p')
              local dir_path = vim.fn.fnamemodify(build_path, ':h')
              return string.format("cd %s && dotnet build \"%s\" %s", dir_path, build_path, args or "")
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
          type = "block_scoped",
          enabled = true
        },
        picker = "telescope"
      })

      -- Global keymappings for .NET development
      vim.keymap.set("n", "<leader>dn", function()
        dotnet.run_project()
      end, { desc = "Run .NET Project" })

      vim.keymap.set("n", "<leader>db", function()
        dotnet.build()
      end, { desc = "Build .NET Project" })

      vim.keymap.set("n", "<leader>dt", function()
        vim.cmd("DotNetTest")
      end, { desc = "Test .NET Project" })

      vim.keymap.set("n", "<leader>dT", function()
        dotnet.testrunner()
      end, { desc = "Open Test Runner" })

      vim.keymap.set("n", "<leader>do", function()
        dotnet.outdated()
      end, { desc = "Check Outdated Packages" })

      vim.keymap.set("n", "<leader>dp", function()
        dotnet.project_view()
      end, { desc = "Project View" })

      vim.keymap.set("n", "<leader>ds", function()
        dotnet.secrets()
      end, { desc = "User Secrets" })

      vim.keymap.set("n", "<leader>da", function()
        dotnet.add_package()
      end, { desc = "Add Package" })

      vim.keymap.set("n", "<leader>dr", function()
        dotnet.remove_package()
      end, { desc = "Remove Package" })

      vim.keymap.set("n", "<leader>dc", function()
        dotnet.clean()
      end, { desc = "Clean Project" })

      vim.keymap.set("n", "<leader>dR", function()
        dotnet.restore()
      end, { desc = "Restore Project" })

      -- Add custom command for running tests with a specific project
      vim.api.nvim_create_user_command('DotNetTest', function(opts)
        local project_path = opts.args
        if project_path == "" then
          -- Try to find a test project in the current directory
          local current_file = vim.fn.expand('%:p')
          local current_dir = vim.fn.fnamemodify(current_file, ':h')

          -- Look for test projects
          local test_projects = vim.fn.globpath(current_dir .. ';', '**/[tT]est*/*.csproj', false, true)
          if #test_projects > 0 then
            project_path = test_projects[1]
          else
            -- Try to find the solution file instead
            local solution_file = find_solution_file()
            if solution_file then
              project_path = solution_file
            else
              vim.notify("No test project or solution found. Please specify a project path.", vim.log.levels.WARN)
              return
            end
          end
        end

        -- Ensure the path is properly quoted and formatted
        project_path = vim.fn.fnamemodify(project_path, ':p')

        -- Run the test with the specified project
        vim.cmd("vsplit")
        vim.cmd(string.format("term cd %s && dotnet test \"%s\"",
          vim.fn.fnamemodify(project_path, ':h'),
          project_path))
      end, {
        nargs = '?',
        desc = 'Run .NET tests with a specific project',
        complete = function()
          local current_dir = vim.fn.expand('%:p:h')
          local test_projects = vim.fn.globpath(current_dir .. ';', '**/[tT]est*/*.csproj', false, true)
          return test_projects
        end
      })

      -- Add command to run tests with a filter
      vim.api.nvim_create_user_command('DotNetTestFilter', function(opts)
        local filter = opts.args
        if filter == "" then
          vim.notify("Please specify a test filter", vim.log.levels.WARN)
          return
        end

        -- Try to find a test project
        local current_file = vim.fn.expand('%:p')
        local current_dir = vim.fn.fnamemodify(current_file, ':h')
        local test_projects = vim.fn.globpath(current_dir .. ';', '**/[tT]est*/*.csproj', false, true)

        local project_path
        if #test_projects > 0 then
          project_path = test_projects[1]
        else
          -- Try to find the solution file instead
          local solution_file = find_solution_file()
          if solution_file then
            project_path = solution_file
          else
            vim.notify("No test project or solution found.", vim.log.levels.WARN)
            return
          end
        end

        -- Ensure the path is properly quoted and formatted
        project_path = vim.fn.fnamemodify(project_path, ':p')

        -- Run the test with the filter
        vim.cmd("vsplit")
        vim.cmd(string.format("term cd %s && dotnet test \"%s\" --filter \"%s\"",
          vim.fn.fnamemodify(project_path, ':h'),
          project_path,
          filter))
      end, {
        nargs = 1,
        desc = 'Run .NET tests with a filter',
      })

      -- Add command to run tests with the current solution
      vim.api.nvim_create_user_command('DotNetTestSolution', function()
        local solution_file = find_solution_file()
        if solution_file then
          -- Ensure the path is properly quoted and formatted
          solution_file = vim.fn.fnamemodify(solution_file, ':p')

          vim.cmd("vsplit")
          vim.cmd(string.format("term cd %s && dotnet test",
            vim.fn.fnamemodify(solution_file, ':h')))
        else
          vim.notify("No solution file found.", vim.log.levels.WARN)
        end
      end, {
        desc = 'Run .NET tests with the current solution'
      })

      -- Add keymapping to test the solution
      vim.keymap.set("n", "<leader>dts", function()
        vim.cmd("DotNetTestSolution")
      end, { desc = "Test .NET Solution" })

      -- Add keymapping for test with filter
      vim.keymap.set("n", "<leader>dtf", function()
        vim.ui.input({ prompt = "Test filter: " }, function(filter)
          if filter and filter ~= "" then
            vim.cmd("DotNetTestFilter " .. filter)
          end
        end)
      end, { desc = "Test .NET with Filter" })

      -- Setup basic completion for .NET project files
      -- Note: We're using standard LSP completion instead of a custom source
      -- since the 'easy-dotnet.cmp' module doesn't exist
      local has_cmp, cmp = pcall(require, "cmp")
      if has_cmp then
        -- Configure completion for .NET project files using standard sources
        cmp.setup.filetype({ "csproj", "fsproj", "sln" }, {
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "buffer" },
          })
        })
      end
    end,
  },
}

