local M = {}
local utils = require("base.utils")

local _vim = vim

if not _vim then
  utils.notify("Error: vim module not found", _vim.log.levels.ERROR)
end

-- Function to safely require a module
---@param source string
---@return table|nil module
---@return string|nil error_message
local function require_module(source)
  local ok, module_or_error = pcall(require, source)
  if not ok then
    -- log.error("Error loading module '%s': %s", source, module_or_error)
    return nil, module_or_error
  end
  return module_or_error, nil
end

-- Function to set up a module by calling its setup function
---@param source string
---@param module table
---@return boolean success
local function setup_module(source, module)
  if type(module) == "table" and type(module.setup) == "function" then
    local setup_ok, setup_err = pcall(module.setup)
    if not setup_ok then
      utils.notify("Error setting up module " .. source .. ": " .. setup_err, _vim.log.levels.ERROR)
      return false
    end
  else
    utils.notify("Module " .. source .. "does not have a setup function " .. setup_err, _vim.log.levels.WARN)
  end
  return true
end

-- Function to load a single source
---@param source string
function load_source(source)
  local module, err = require_module(source)
  if not module then
    utils.notify("Error loading " .. source .. ": " .. err, _vim.log.levels.ERROR)
    return
  end

  local setup_success = setup_module(source, module)
  if not setup_success then
    utils.notify("Error setting up " .. source, _vim.log.levels.ERROR)
    return
  end
end

-- Function to load multiple sources
---@param sources table
function load_sources(sources)
  _vim.loader.enable()
  if type(sources) ~= "table" then
    utils.notify("Expected a table of sources, got " .. type(sources), _vim.log.levels.ERROR)
    return
  end

  for _, source in ipairs(sources) do
    load_source(source)
  end
end

function load_mappings_async(sources)
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
    "base.keymaps",
  }

  -- Load sources and mappings
  load_sources(sources)
end

return M
