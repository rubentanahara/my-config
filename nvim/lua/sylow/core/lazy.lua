local M = {}

-- Constants
local LAZY_PATH = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local LAZY_REPO = 'https://github.com/folke/lazy.nvim.git'
local LAZY_ROCKS_ENABLED = vim.fn.executable('luarocks') == 1

-- Icons configuration
local ICONS = {
  cmd = '⌘',
  config = '🛠',
  event = '📅',
  ft = '📂',
  init = '⚙',
  keys = '🔑',
  plugin = '🔌',
  runtime = '💻',
  source = '📄',
  start = '🚀',
  task = '📌',
  lazy = '💤',
}

-- Disabled built-in plugins
local DISABLED_PLUGINS = {
  'gzip',
  'tarPlugin',
  'tohtml',
  'tutor',
  'zipPlugin',
}

local function clone_lazy()
  vim.notify('Cloning Lazy.nvim from repository...', vim.log.levels.INFO)
  local output = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    LAZY_REPO,
    LAZY_PATH,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { output, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
    return false
  end
  return true
end

local function setup_post_install_loads(plugins)
  local original_cmdheight = vim.opt.cmdheight:get()
  vim.opt.cmdheight = 1

  vim.api.nvim_create_autocmd('User', {
    pattern = 'LazyInstall',
    once = true,
    callback = function()
      vim.cmd.bw()
      vim.opt.cmdheight = original_cmdheight

      for _, module in ipairs(plugins) do
        local ok, err = pcall(require, module)
        if not ok then
          vim.notify('Failed to load plugin module: ' .. module .. '\n' .. tostring(err), vim.log.levels.ERROR)
        else
          vim.notify('Loaded plugin module: ' .. module, vim.log.levels.INFO)
        end
      end
    end,
    desc = 'Load plugins after Lazy installation completes',
  })
end

--- Get plugin specification for Lazy
--- @return table spec Plugin specification table
local function get_plugin_spec()
  local spec = {}
  local plugin_categories = {
    'sylow.plugins',
    'sylow.plugins.ui',
    'sylow.plugins.editor',
    'sylow.plugins.tools',
    'sylow.plugins.code',
    'sylow.plugins.lsp',
    'sylow.plugins.dap',
    'sylow.plugins.ai',
    'sylow.plugins.testing',
  }

  for _, category in ipairs(plugin_categories) do
    table.insert(spec, { import = category })
  end

  return spec
end

local function initialize_lazy(lazy_path)
  vim.opt.rtp:prepend(lazy_path)

  local ok, lazy = pcall(require, 'lazy')
  if not ok then
    vim.notify("Failed to require 'lazy' after installation", vim.log.levels.ERROR)
    return
  end

  local lazy_config = {
    spec = get_plugin_spec(),
    defaults = { lazy = false, version = false },
    performance = {
      rtp = {
        disabled_plugins = DISABLED_PLUGINS,
      },
    },
    checker = {
      enabled = true, -- check for plugin updates periodically
      notify = true, -- notify on update
    },
    ui = { icons = ICONS },
    rocks = { enabled = LAZY_ROCKS_ENABLED },
  }

  lazy.setup(lazy_config)
end

function M.setup()
  local is_first_startup = not (vim.uv or vim.loop).fs_stat(LAZY_PATH)

  if is_first_startup then
    vim.notify('First time setup: Lazy.nvim not found, cloning...', vim.log.levels.INFO)
    if not clone_lazy() then
      vim.notify('Lazy.nvim setup failed: could not clone repository', vim.log.levels.ERROR)
      return false
    end

    setup_post_install_loads({ 'nvim-treesitter', 'mason' })
  end

  initialize_lazy(LAZY_PATH)
  return true
end

return M
