return {
  'mfussenegger/nvim-dap',
  opts = function()
    local dap = require('dap')
    if not dap.adapters['netcoredbg'] then
      require('dap').adapters['netcoredbg'] = {
        type = 'executable',
        command = vim.fn.exepath('netcoredbg'),
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
            ---@diagnostic disable-next-line: redundant-parameter
            program = function()
              return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = '${workspaceFolder}',
          },
        }
      end
    end
  end,
}
