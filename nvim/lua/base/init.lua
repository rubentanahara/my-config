local M = {}
local utils = require("base.utils")

if not utils then
  -- echo error
  print("Error: utils module not found")
end

local _vim = vim

if not _vim then
  utils.notify("Error: vim module not found", _vim.log.levels.ERROR)
end

function M.load_source(source)
  local ok, mod_or_err = pcall(require, source)
  if not ok then
    utils.notify("Error loading " .. source .. ": " .. mod_or_err, _vim.log.levels.ERROR)
    return
  end

  if type(mod_or_err) == "table" and type(mod_or_err.setup) == "function" then
    local setup_ok, setup_err = pcall(mod_or_err.setup)
    if not setup_ok then
      utils.notify("Error setting up " .. source .. ": " .. setup_err, _vim.log.levels.ERROR)
    end
  end
end

function M.load_sources(sources)
  _vim.loader.enable()
  if type(sources) ~= "table" then
    utils.notify("Expected a table of sources, got " .. type(sources), _vim.log.levels.ERROR)
    return
  end

  for _, source in ipairs(sources) do
    M.load_source(source)
  end
end

function M.load_mappings_async(sources)
  for _, source in ipairs(sources) do
    _vim.defer_fn(function()
      M.load_source(source)
    end, 50)
  end
end

function M.init()
  local sources = {
    "base.options",
    "base.lazy",
    "base.autocmds",
  }

  local mappings = {
    -- "base.keymaps",
  }

  -- Load sources and mappings
  M.load_sources(sources)
  M.load_mappings_async(mappings)
end

return M
