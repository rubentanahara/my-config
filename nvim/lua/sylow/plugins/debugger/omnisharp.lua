return {
  {
    'williamboman/mason.nvim',
    opts = {
      ensure_installed = {
        'netcoredbg',
      },
    },
  },
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'nvim-lua/plenary.nvim', -- Required for path operations
    },
    config = function()
      local dap = require('dap')

      -- Use netcoredbg from Mason installation
      local mason_path = vim.fn.stdpath('data') .. '/mason/packages/netcoredbg/netcoredbg'

      local netcoredbg_adapter = {
        type = 'executable',
        command = mason_path,
        args = { '--interpreter=vscode' },
        -- options = {
        -- 	detached = false,
        -- },
      }

      -- Set up adapters
      dap.adapters.netcoredbg = netcoredbg_adapter -- for normal debugging
      dap.adapters.coreclr = netcoredbg_adapter -- for unit test debugging

      -- DLL auto-detection functions
      local function find_project_root_by_csproj(start_path)
        local Path = require('plenary.path')
        local path = Path:new(start_path)

        while true do
          local csproj_files = vim.fn.glob(path:absolute() .. '/*.csproj', false, true)
          if #csproj_files > 0 then
            return path:absolute()
          end

          local parent = path:parent()
          if parent:absolute() == path:absolute() then
            return nil
          end

          path = parent
        end
      end

      local function get_highest_net_folder(bin_debug_path)
        local dirs = vim.fn.glob(bin_debug_path .. '/net*', false, true)

        if #dirs == 0 then
          error('No netX.Y folders found in ' .. bin_debug_path)
        end

        table.sort(dirs, function(a, b)
          local ver_a = tonumber(a:match('net(%d+)%.%d+')) or tonumber(a:match('net(%d+)'))
          local ver_b = tonumber(b:match('net(%d+)%.%d+')) or tonumber(b:match('net(%d+)'))
          return (ver_a or 0) > (ver_b or 0)
        end)

        return dirs[1]
      end

      local function build_dll_path()
        local current_file = vim.api.nvim_buf_get_name(0)
        local current_dir = vim.fn.fnamemodify(current_file, ':p:h')

        local project_root = find_project_root_by_csproj(current_dir)
        if not project_root then
          error('Could not find project root (no .csproj found)')
        end

        local csproj_files = vim.fn.glob(project_root .. '/*.csproj', false, true)
        if #csproj_files == 0 then
          error('No .csproj file found in project root')
        end

        local project_name = vim.fn.fnamemodify(csproj_files[1], ':t:r')
        local bin_debug_path = project_root .. '/bin/Debug'
        local highest_net_folder = get_highest_net_folder(bin_debug_path)
        local dll_path = highest_net_folder .. '/' .. project_name .. '.dll'

        print('Launching: ' .. dll_path)
        return dll_path
      end

      -- Configure debugging for .NET languages
      dap.configurations.cs = {
        {
          type = 'netcoredbg',
          name = 'Launch (Auto-detect DLL)',
          request = 'launch',
          program = build_dll_path,
          cwd = '${workspaceFolder}',
          stopAtEntry = false,
          console = 'integratedTerminal',
        },
        {
          type = 'netcoredbg',
          name = 'Launch (Manual DLL)',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtEntry = false,
          console = 'integratedTerminal',
        },
        {
          type = 'netcoredbg',
          name = 'Attach to Process',
          request = 'attach',
          processId = function()
            return require('dap.utils').pick_process()
          end,
        },
      }
    end,
  },
}
