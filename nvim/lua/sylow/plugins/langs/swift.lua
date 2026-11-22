local function configure_sourcekit()
  vim.lsp.config('sourcekit', {
    filetypes = { 'swift', 'objc', 'objcpp' },
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
  })
  vim.lsp.enable('sourcekit')
end

local function format_swift_on_save()
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('SwiftFormat', { clear = true }),
    pattern = '*.swift',
    callback = function(args)
      local autoformat_enabled = vim.b[args.buf].autoformat_enabled
      if autoformat_enabled == nil then
        autoformat_enabled = vim.g.autoformat_enabled
      end
      if autoformat_enabled then
        require('conform').format({ bufnr = args.buf })
      end
    end,
  })
end

local function lint_swift_on_change()
  local lint = require('lint')
  lint.linters_by_ft = { swift = { 'swiftlint' } }
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost', 'InsertLeave' }, {
    group = vim.api.nvim_create_augroup('SwiftLint', { clear = true }),
    pattern = '*.swift',
    callback = function()
      lint.try_lint()
    end,
  })
  lint.try_lint()
end

local function debug_after_build()
  require('xcodebuild.integrations.dap').build_and_debug()
end

return {
  {
    'wojciech-kulik/xcodebuild.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'MunifTanjim/nui.nvim',
    },
    ft = { 'swift', 'objc' },
    cmd = { 'XcodebuildSetup', 'XcodebuildPicker' },
    keys = {
      { '<leader>XX', '<cmd>XcodebuildPicker<cr>', desc = 'Xcode actions' },
      { '<leader>Xf', '<cmd>XcodebuildProjectManager<cr>', desc = 'Project manager' },
      { '<leader>Xb', '<cmd>XcodebuildBuild<cr>', desc = 'Build' },
      { '<leader>Xr', '<cmd>XcodebuildBuildRun<cr>', desc = 'Build & run' },
      { '<leader>XD', debug_after_build, desc = 'Build & debug' },
      { '<leader>Xt', '<cmd>XcodebuildTest<cr>', desc = 'Run tests' },
      { '<leader>Xt', '<cmd>XcodebuildTestSelected<cr>', mode = 'v', desc = 'Run selected tests' },
      { '<leader>XT', '<cmd>XcodebuildTestClass<cr>', desc = 'Run test class' },
      { '<leader>Xe', '<cmd>XcodebuildTestExplorerToggle<cr>', desc = 'Test explorer' },
      { '<leader>Xl', '<cmd>XcodebuildToggleLogs<cr>', desc = 'Toggle logs' },
      { '<leader>Xd', '<cmd>XcodebuildSelectDevice<cr>', desc = 'Select device' },
    },
    init = function()
      configure_sourcekit()
      format_swift_on_save()
    end,
    config = function()
      require('xcodebuild').setup({})
      require('xcodebuild.integrations.dap').setup()
    end,
  },
  {
    'mfussenegger/nvim-lint',
    ft = { 'swift' },
    config = lint_swift_on_change,
  },
}
