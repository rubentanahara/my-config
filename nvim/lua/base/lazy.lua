local M = {}
local _vim = vim
local utils = require("base.utils")
local opt = _vim.opt
local fn = _vim.fn
local api = _vim.api
local uv = _vim.uv
local cmd = _vim.cmd

function M.setup()
  -- Lazy updater options
  -- Use the same values you have in the plugin `distroupdate.nvim`
  local updates_config = {
    channel = "stable",                  -- 'nightly', or 'stable'
    snapshot_file = "lazy_snapshot.lua", -- plugins lockfile created by running the command ':DistroFreezePluginVersions' provided by `distroupdate.nvim`.
  }

  --- Download 'lazy' from its git repository if lazy_dir doesn't exists already.
  --- Note: This function should ONLY run the first time you start nvim.
  --- @param lazy_dir string Path to clone lazy into. Recommended: `<nvim data dir>/lazy/lazy.nvim`
  local function git_clone_lazy(lazy_dir)
    local output = fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      "https://github.com/folke/lazy.nvim.git",
      lazy_dir,
    })
    if api.nvim_get_vvar("shell_error") ~= 0 then
      utils.notify(
        "Error cloning lazy.nvim: " .. output,
        _vim.log.levels.ERROR
      )
    end
  end

  --- This functions creates a one time autocmd to load the plugins passed.
  --- This is useful for plugins that will trigger their own update mechanism when loaded.
  ---
  --- Note: This function should ONLY run the first time you start nvim.
  --- @param plugins string[] plugins to load right after lazy end installing all.
  local function after_installing_plugins_load(plugins)
    local oldcmdheight = opt.cmdheight:get()
    opt.cmdheight = 1
    api.nvim_create_autocmd("User", {
      pattern = "LazyInstall",
      once = true,
      callback = function()
        cmd.bw()
        opt.cmdheight = oldcmdheight
        _vim.tbl_map(function(module) pcall(require, module) end, plugins)
        -- Note: Loading mason and treesitter will trigger updates there too if necessary.
      end,
      desc = "Load Mason and Treesitter after Lazy installs plugins",
    })
  end

  --- load `<config_dir>/lua/lazy_snapshot.lua` and return it as table.
  --- @return table spec A table you can pass to the `spec` option of lazy.
  local function get_lazy_spec()
    local snapshot_filename = fn.fnamemodify(updates_config.snapshot_file, ":t:r")
    local pin_plugins = updates_config.channel == "stable"
    local snapshot_file_exists = uv.fs_stat(
      fn.stdpath("config")
      .. "/lua/"
      .. snapshot_filename
      .. ".lua"
    )
    local spec = pin_plugins
        and snapshot_file_exists
        and { { import = snapshot_filename } }
        or {}
    _vim.list_extend(spec, { { import = "plugins" } })

    return spec
  end

  --- Require lazy and pass the spec.
  --- @param lazy_dir string used to specify neovim where to find the lazy_dir.
  local function setup_lazy(lazy_dir)
    local spec = get_lazy_spec()

    opt.rtp:prepend(lazy_dir)
    require("lazy").setup({
      spec = spec,
      defaults = { lazy = true },
      performance = {
        rtp = {
          disabled_plugins = {
            "gzip",
            "matchit",
            "matchparen",
            "netrwPlugin",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
          },
        },
      },
      ui = {
        icons = {
          cmd = "⌘",
          config = "🛠",
          event = "📅",
          ft = "📂",
          init = "⚙",
          keys = "🔑",
          plugin = "🔌",
          runtime = "💻",
          source = "📄",
          start = "🚀",
          task = "📌",
          lazy = "💤"
        },
      },
      -- Enable luarocks if installed.
      rocks = { enabled = fn.executable("luarocks") == 1 },
      -- We don't use this, so create it in a disposable place.
      lockfile = fn.stdpath("cache") .. "/lazy-lock.json",
    })
  end

  local lazy_dir = fn.stdpath("data") .. "/lazy/lazy.nvim"
  local is_first_startup = not uv.fs_stat(lazy_dir)

  -- Call the functions defined above.
  if is_first_startup then
    git_clone_lazy(lazy_dir)
    after_installing_plugins_load({ "nvim-treesitter", "mason" })
    utils.notify("Please wait while plugins are installed...", _vim.log.levels.INFO)
  end
  setup_lazy(lazy_dir)
end

return M
