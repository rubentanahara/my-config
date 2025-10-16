-- Helper functions
local function splitstr(str)
  local result = {}
  for match in (str .. ' '):gmatch('(.-) ') do
    if match ~= '' then
      table.insert(result, match)
    end
  end
  return result
end

local function get_args(config)
  local args = type(config.args) == 'function' and (config.args() or {}) or config.args or {}
  local args_str = type(args) == 'table' and table.concat(args, ' ') or args

  config = vim.deepcopy(config)
  config.args = function()
    local new_args = vim.fn.expand(vim.fn.input('Run with args: ', args_str))
    if config.type and config.type == 'java' then
      return new_args
    end
    return splitstr(new_args)
  end
  return config
end

-- Key mappings
local function get_dap_keys()
  return {
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end,
      desc = 'Breakpoint Condition',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Toggle Breakpoint',
    },
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Run/Continue',
    },
    {
      '<leader>da',
      function()
        require('dap').continue({ before = get_args })
      end,
      desc = 'Run with Args',
    },
    {
      '<leader>dC',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Run to Cursor',
    },
    {
      '<leader>dg',
      function()
        require('dap').goto_()
      end,
      desc = 'Go to Line (No Execute)',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'Step Into',
    },
    {
      '<leader>dj',
      function()
        require('dap').down()
      end,
      desc = 'Down',
    },
    {
      '<leader>dk',
      function()
        require('dap').up()
      end,
      desc = 'Up',
    },
    {
      '<leader>dl',
      function()
        require('dap').run_last()
      end,
      desc = 'Run Last',
    },
    {
      '<leader>do',
      function()
        require('dap').step_out()
      end,
      desc = 'Step Out',
    },
    {
      '<leader>dO',
      function()
        require('dap').step_over()
      end,
      desc = 'Step Over',
    },
    {
      '<leader>dP',
      function()
        require('dap').pause()
      end,
      desc = 'Pause',
    },
    {
      '<leader>dr',
      function()
        require('dap').repl.toggle()
      end,
      desc = 'Toggle REPL',
    },
    {
      '<leader>ds',
      function()
        require('dap').session()
      end,
      desc = 'Session',
    },
    {
      '<leader>dt',
      function()
        require('dap').terminate()
      end,
      desc = 'Terminate',
    },
    {
      '<leader>dw',
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = 'Widgets',
    },
  }
end

local function get_dapui_keys()
  return {
    {
      '<leader>du',
      function()
        require('dapui').toggle({})
      end,
      desc = 'Dap UI',
    },
    {
      '<leader>de',
      function()
        require('dapui').eval()
      end,
      desc = 'Eval',
      mode = { 'n', 'v' },
    },
  }
end

-- Language-specific debugger configurations
local function setup_language_debuggers()
  local dap = require('dap')
  local utils = require('sylow.utils')
  local is_windows = utils.is_windows()
  local is_mac = utils.is_mac()
  local is_arm = utils.is_arm64()

  -- C#
  if is_mac and is_arm then
    require('netcoredbg-macOS-arm64').setup(dap)
  else
    local mason_path = vim.fn.stdpath('data') .. '/mason/packages/netcoredbg/netcoredbg'
    local netcoredbg_adapter = {
      type = 'executable',
      command = mason_path,
      args = { '--interpreter=vscode' },
    }

    dap.adapters.netcoredbg = netcoredbg_adapter -- needed for normal debugging
    dap.adapters.coreclr = netcoredbg_adapter -- needed for unit test debugging
    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'NetCoreDbg: Launch',
        request = 'launch',
        cwd = '${fileDirname}',
        program = function()
          utils.build_dll_path()
        end,
      },
    }
  end

  -- Python
  dap.adapters.python = {
    type = 'executable',
    command = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python',
    args = { '-m', 'debugpy.adapter' },
  }
  dap.configurations.python = {
    {
      type = 'python',
      request = 'launch',
      name = 'Launch file',
      program = '${file}',
    },
  }

  -- C/C++/Rust
  dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
      command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
      args = { '--port', '${port}' },
      detached = not is_windows,
    },
  }

  -- C/C++
  dap.configurations.cpp = {
    {
      name = 'Debug Executable',
      type = 'codelldb',
      request = 'launch',
      program = function()
        -- Find all executable files in build or cmake-build directories
        local search_dirs = {
          vim.fn.getcwd() .. '/build/',
          vim.fn.getcwd() .. '/cmake-build/',
          vim.fn.getcwd() .. '/target/debug/', -- Added for Rust-like projects
        }

        local executables = {}
        for _, dir in ipairs(search_dirs) do
          local files = vim.fn.globpath(dir, '*', false, true)
          local dir_executables = vim.tbl_filter(function(file)
            local filename = vim.fn.fnamemodify(file, ':t')
            return not filename:match('^%.')
              and not filename:match('%.so$')
              and not filename:match('%.a$')
              and not filename:match('%.d$')
          end, files)

          vim.list_extend(executables, dir_executables)
        end

        -- If only one executable found, use it
        if #executables == 1 then
          return executables[1]
        end

        -- If multiple executables, let user choose
        if #executables > 1 then
          return vim.ui.select(executables, {
            prompt = 'Select executable to debug:',
            format_item = function(file)
              return vim.fn.fnamemodify(file, ':t')
            end,
          }, function(choice)
            return choice
          end)
        end

        -- Fallback to manual input if no executables found
        return vim.fn.input('Path to executable: ', vim.fn.getcwd(), 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
    },
  }

  dap.configurations.c = dap.configurations.cpp

  -- Rust
  dap.configurations.rust = {
    {
      name = 'Debug Executable',
      type = 'codelldb',
      request = 'launch',
      program = function()
        -- Find all executable files in target/debug directory
        local debug_dir = vim.fn.getcwd() .. '/target/debug/'
        local files = vim.fn.globpath(debug_dir, '*', false, true)

        -- Filter out files that are not executables
        local executables = vim.tbl_filter(function(file)
          local filename = vim.fn.fnamemodify(file, ':t')
          -- Ignore common non-executable files
          return not filename:match('^%.') -- Ignore hidden files
            and not filename:match('%.so$') -- Ignore shared libraries
            and not filename:match('%.a$') -- Ignore static libraries
            and not filename:match('%.d$') -- Ignore dependency files
            and not filename:match('%.rlib$') -- Ignore Rust library files
        end, files)

        -- If only one executable found, use it
        if #executables == 1 then
          return executables[1]
        end

        -- If multiple executables, let user choose
        if #executables > 1 then
          -- Use a coroutine to handle the async selection
          local co = coroutine.running()
          if co then
            vim.ui.select(executables, {
              prompt = 'Select executable to debug:',
              format_item = function(file)
                return vim.fn.fnamemodify(file, ':t')
              end,
            }, function(choice)
              coroutine.resume(co, choice)
            end)
            return coroutine.yield()
          else
            -- Fallback if not in coroutine context
            print('Multiple executables found, using first one: ' .. executables[1])
            return executables[1]
          end
        end

        -- Fallback to manual input if no executables found
        return vim.fn.input('Path to executable: ', debug_dir, 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
    },
  }

  -- Go
  dap.adapters.delve = {
    type = 'server',
    port = '${port}',
    executable = {
      command = vim.fn.stdpath('data') .. '/mason/packages/delve/dlv',
      args = { 'dap', '-l', '127.0.0.1:${port}' },
    },
  }
  dap.configurations.go = {
    {
      type = 'delve',
      name = 'Debug file',
      request = 'launch',
      program = './${relativeFileDirname}',
    },
  }

  -- JavaScript/TypeScript
  dap.adapters.node2 = {
    type = 'executable',
    command = vim.fn.stdpath('data') .. '/mason/bin/js-debug-adapter',
  }
  dap.configurations.javascript = {
    {
      name = 'Launch',
      type = 'node2',
      request = 'launch',
      program = '${file}',
      cwd = vim.fn.getcwd(),
    },
  }
  dap.configurations.typescript = dap.configurations.javascript
  dap.configurations.javascriptreact = dap.configurations.javascript
  dap.configurations.typescriptreact = dap.configurations.javascript

  -- Lua
  dap.adapters.nlua = function(callback, config)
    callback({ type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 })
  end
  dap.configurations.lua = {
    {
      type = 'nlua',
      request = 'attach',
      name = 'Attach to Neovim',
      program = function()
        pcall(require 'osv'.launch({ port = 8086 }))
      end,
    },
  }

  -- Dart/Flutter
  dap.adapters.dart = {
    type = 'executable',
    command = vim.fn.stdpath('data') .. '/mason/bin/dart-debug-adapter',
    args = { 'dart' },
  }
  dap.adapters.flutter = {
    type = 'executable',
    command = vim.fn.stdpath('data') .. '/mason/bin/dart-debug-adapter',
    args = { 'flutter' },
  }
  dap.configurations.dart = {
    {
      type = 'dart',
      request = 'launch',
      name = 'Launch Dart',
      program = '${workspaceFolder}/lib/main.dart',
    },
  }

  -- Java (via nvim-java)
  -- Note: Requires nvim-java plugin
  -- Kotlin
  dap.adapters.kotlin = {
    type = 'executable',
    command = vim.fn.stdpath('data') .. '/mason/bin/kotlin-debug-adapter',
  }
  dap.configurations.kotlin = {
    {
      type = 'kotlin',
      request = 'launch',
      name = 'Launch Kotlin',
      projectRoot = '${workspaceFolder}',
    },
  }
end

-- Base DAP setup
local function setup_dap()
  vim.api.nvim_set_hl(0, 'DapStoppedLine', { default = true, link = 'Visual' })

  -- Setup language configurations
  setup_language_debuggers()

  -- VSCode launch.json support
  local vscode = require('dap.ext.vscode')
  local json = require('plenary.json')
  vscode.json_decode = function(str)
    return vim.json.decode(json.json_strip_comments(str))
  end
end

-- DAP UI setup
local function setup_dapui(_, opts)
  local dap = require('dap')
  local dapui = require('dapui')
  dapui.setup(opts)

  -- Auto open/close DAP UI
  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end
end

-- Mason DAP setup
local function setup_mason_dap()
  return {
    automatic_installation = true,
    ensure_installed = {
      'netcoredbg', -- C#
      'codelldb', -- C/C++/Rust
      'debugpy', -- Python
      'js-debug-adapter', -- JavaScript/TypeScript
      'dart-debug-adapter', -- Dart/Flutter
      'kotlin-debug-adapter', -- Kotlin
    },
  }
end

return {
  -- Main DAP plugin
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    keys = get_dap_keys,
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'jay-babu/mason-nvim-dap.nvim',
    },
    config = setup_dap,
  },

  -- DAP Virtual Text
  {
    'theHamsta/nvim-dap-virtual-text',
    dependencies = { 'mfussenegger/nvim-dap' },
    opts = {
      enabled = true,
      highlight_changed_variables = true,
      show_stop_reason = true,
    },
    config = function(_, opts)
      require('nvim-dap-virtual-text').setup(opts)
    end,
  },

  -- DAP UI
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    keys = get_dapui_keys,
    opts = {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.25 },
            { id = 'breakpoints', size = 0.25 },
            { id = 'stacks', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          size = 10,
          position = 'bottom',
        },
      },
    },
    config = setup_dapui,
  },

  -- Mason DAP integration
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'mfussenegger/nvim-dap',
    },
    cmd = { 'DapInstall', 'DapUninstall' },
    opts = setup_mason_dap,
    config = function(_, opts)
      require('mason-nvim-dap').setup(opts)
    end,
  },
}
