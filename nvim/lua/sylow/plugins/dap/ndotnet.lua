return {
  {
    'mfussenegger/nvim-dap',
    opts = function()
      local dap = require('dap')
      if not dap.adapters['netcoredbg'] then
        local netcoredbg_path = vim.fn.exepath('netcoredbg')
        print(netcoredbg_path)
        if netcoredbg_path == '' then
          vim.notify(
            'netcoredbg not found in PATH. Please install it and ensure it is available.',
            vim.log.levels.ERROR
          )
          return
        end
        require('dap').adapters['netcoredbg'] = {
          type = 'executable',
          command = netcoredbg_path,
          args = { '--interpreter=vscode' },
          options = {
            detached = false,
          },
        }
      end
      for _, lang in ipairs({ 'cs', 'fsharp', 'vb' }) do
        if not dap.configurations[lang] then
          dap.configurations[lang] = {
            {
              type = 'netcoredbg',
              name = 'Launch file',
              request = 'launch',
              program = function()
                return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug', 'file')
              end,
              cwd = '${workspaceFolder}',
            },
          }
        end
      end
    end,
  },
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = {
      'Issafalcon/neotest-dotnet',
    },
    opts = {
      adapters = {
        ['neotest-dotnet'] = {
          -- Here we can set options for neotest-dotnet
        },
      },
    },
  },
}
