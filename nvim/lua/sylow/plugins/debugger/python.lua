return {
  'mfussenegger/nvim-dap-python',
  ft = 'python',
  dependencies = {
    'mfussenegger/nvim-dap',
    'rcarriga/nvim-dap-ui',
  },
  keys = {
    {
      '<leader>dPt',
      function()
        require('dap-python').test_method()
      end,
      desc = 'Debug Method',
      ft = 'python',
    },
    {
      '<leader>dPc',
      function()
        require('dap-python').test_class()
      end,
      desc = 'Debug Class',
      ft = 'python',
    },
  },
  config = function()
    local mason_path = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python'
    require('dap-python').setup(mason_path)
  end,
}
