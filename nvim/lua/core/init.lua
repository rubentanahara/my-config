-- Core initialization
local M = {}

-- Initialize core functionality
function M.setup()
  -- Load core modules
  require("core.options").setup()
  require("core.keymaps").setup()
  require("core.autocmds").setup()
end

-- Global utility functions
M.utils = {
  -- Check if a plugin is available
  has = function(plugin)
    return require("lazy.core.config").spec.plugins[plugin] ~= nil
  end,

  -- Load a module safely
  require_safe = function(module)
    local ok, result = pcall(require, module)
    if not ok then
      vim.notify("Error loading " .. module, vim.log.levels.ERROR)
      return nil
    end
    return result
  end,

  -- Create autocommand group
  augroup = function(name)
    return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
  end,

  -- Map keys with description
  map = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end,
}

return M 