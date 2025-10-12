local utils = require("sylow.core.utils")

local LAZY_PATH = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local LAZY_REPO = 'https://github.com/folke/lazy.nvim.git'
local LAZY_ROCKS_ENABLED = vim.fn.executable('luarocks') == 1

local vim_version = vim.version()
if vim_version.major < 0 or (vim_version.major == 0 and vim_version.minor < 8) then
  vim.api.nvim_err_writeln('Neovim 0.8 or higher is required for this configuration')
  return
end

-- Disabled built-in plugins
local DISABLED_PLUGINS = {
  'gzip',
  'tarPlugin',
  'tutor',
  'zipPlugin',
}

local function clone_lazy()
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

local function initialize_lazy(lazy_path)
  vim.opt.rtp:prepend(lazy_path)

  local ok, lazy = pcall(require, 'lazy')
  if not ok then
    vim.notify("Failed to require 'lazy' after installation", vim.log.levels.ERROR)
    return
  end

  local function get_plugin_spec()
    local spec = {}
    local plugin_categories = {
      'sylow.plugins',
      'sylow.plugins.ui',
      'sylow.plugins.editor',
      'sylow.plugins.ai',
      'sylow.plugins.code',
      'sylow.plugins.debugger',
      'sylow.plugins.lsp',
      -- 'sylow.plugins.tools',
      -- 'sylow.plugins.testing',
    }

    for _, category in ipairs(plugin_categories) do
      table.insert(spec, { import = category })
    end

    return spec
  end

  local lazy_config = {
    spec = get_plugin_spec(),
    defaults = { lazy = true, version = false },
    performance = {
      rtp = {
        disabled_plugins = DISABLED_PLUGINS,
      },
    },
    checker = {
      enabled = false, -- check for plugin updates periodically turn off
      notify = true, -- notify on update
    },
    rocks = { enabled = LAZY_ROCKS_ENABLED },
  }

  lazy.setup(lazy_config)
end

local is_first_startup = not (vim.uv or vim.loop).fs_stat(LAZY_PATH)

if is_first_startup then
  utils.notify('First time setup: Lazy.nvim not found, cloning...', vim.log.levels.INFO)
  if not clone_lazy() then
    vim.notify('Lazy.nvim setup failed: could not clone repository', vim.log.levels.ERROR)
    return false
  end

  setup_post_install_loads({ 'nvim-treesitter', 'mason' })
end

initialize_lazy(LAZY_PATH)
