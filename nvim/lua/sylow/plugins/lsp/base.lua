local lsp_utils = require('sylow.utils.lsp')
local utils = require('sylow.utils')
local get_icon = utils.get_icon

local function setup_mason()
  return {
    registries = {
      'github:nvim-java/mason-registry',
      'github:mason-org/mason-registry',
      'github:Crashdummyy/mason-registry',
    },
    ui = {
      icons = {
        package_installed = get_icon('MasonInstalled'),
        package_uninstalled = get_icon('MasonUninstalled'),
        package_pending = get_icon('MasonPending'),
      },
    },
  }
end

local function setup_mason_tool_installer()
  return {
    ensure_installed = {
      -- Formatters
      'stylua', -- lua
      'prettier', -- js,ts
      'csharpier', -- cs
      'rustfmt', -- rust
      'black', -- python
      'xmlformatter',
      -- Linters
      'luacheck', -- lua
      'eslint_d', -- js,ts
      'bacon', -- rust
      'flake8', -- python
      -- DAPs
      'js-debug-adapter', -- js,ts
      'netcoredbg', -- cs
      'codelldb', -- rust
      'debugpy', -- python
      'roslyn', --cs
    },
    auto_update = false,
    run_on_start = true,
  }
end

local function setup_mason_lspconfig()
  return {
    ensure_installed = {
      'lua_ls', -- lua
      'ts_ls', -- js,ts
      'rust_analyzer', -- rust
      'pyright', -- python
    },
    handlers = {
      function(server_name)
        local opts = lsp_utils.apply_user_lsp_settings(server_name)
        require('lspconfig')[server_name].setup(opts)
      end,
    },
  }
end

local mason_keys = {
  { '<leader>cmo', '<cmd>Mason<cr>', desc = 'Mason' },
  { '<leader>cmi', '<cmd>MasonInstall<cr>', desc = 'Mason Install' },
  { '<leader>cmu', '<cmd>MasonUninstall<cr>', desc = 'Mason Uninstall' },
  { '<leader>cma', '<cmd>MasonUninstallAll<cr>', desc = 'Mason Uninstall All' },
  { '<leader>cml', '<cmd>MasonLog<cr>', desc = 'Mason Log' },
  { '<leader>cmU', '<cmd>MasonUpdate<cr>', desc = 'Mason Update' },
}

local mason_cmds = {
  'Mason',
  'MasonInstall',
  'MasonUninstall',
  'MasonUninstallAll',
  'MasonLog',
  'MasonUpdate',
}

return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'williamboman/mason.nvim',
    cmd = mason_cmds,
    keys = mason_keys,
    build = ':MasonUpdate',
    opts = setup_mason,
    config = function(_, opts)
      require('mason').setup(opts)
    end,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = setup_mason_tool_installer,
    config = function(_, opts)
      require('mason-tool-installer').setup(opts)
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = setup_mason_lspconfig,
    config = function(_, opts)
      require('mason-lspconfig').setup(opts)
    end,
  },
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    config = function()
      lsp_utils.apply_default_lsp_settings()
    end,
  },
}
