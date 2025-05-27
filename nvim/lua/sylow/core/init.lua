local M = {}

local CONFIG_SOURCES = { 'sylow.core.options', 'sylow.core.autocmds', 'sylow.core.lazy', 'sylow.core.mappings' }

local function require_module(source)
  local ok, module_or_err = pcall(require, source)
  if not ok then
    vim.notify("Failed to load module '" .. source .. "': " .. tostring(module_or_err), vim.log.levels.ERROR)
    return nil, tostring(module_or_err)
  end

  return module_or_err, nil
end

local function setup_module(source, module)
  if type(module.setup) ~= 'function' then
    vim.notify("Module '" .. source .. "' does not have a setup function", vim.log.levels.WARN)
    return false
  end

  local ok, err = pcall(module.setup)
  if not ok then
    vim.notify("Failed to initialize module '" .. source .. "': " .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  return ok
end

local function load_source(source)
  local module = require_module(source)
  if not module then
    return false
  end

  return setup_module(source, module)
end

local function load_sources(sources)
  vim.loader.enable()

  local success = true
  for _, source in ipairs(sources) do
    success = load_source(source) and success
  end

  return success
end

function M.init()
  return load_sources(CONFIG_SOURCES)
end

return M
