local M = {}

function M.setup()
  require("base.options").setup()
  require("base.keymaps").setup()
  require("base.autocmds").setup()
end

M.utils = {
  has = function(plugin)
    return require("lazy.core.config").spec.plugins[plugin] ~= nil
  end,

  require_safe = function(module)
    local ok, result = pcall(require, module)
    if not ok then
      vim.notify("Error loading " .. module, vim.log.levels.ERROR)
      return nil
    end
    return result
  end,

  augroup = function(name)
    return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
  end,

  map = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end,
}

return M
