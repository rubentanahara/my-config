local M = {}

local api = vim.api

local function create_augroup(name)
  return api.nvim_create_augroup('sylow_' .. name, { clear = true })
end


function M.start_hlslens()
  require('hlslens').start()
end

function M.create_autocmd(event, opts)
  opts.group = opts.group or create_augroup(opts.desc:gsub('%s+', '_'):lower())
  return api.nvim_create_autocmd(event, opts)
end

function M.del_autocmds_from_buffer(augroup, bufnr)
  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })

  if cmds_found then
    vim.tbl_map(function(cmd)
      vim.api.nvim_del_autocmd(cmd.id)
    end, cmds)
  end
end

function M.add_autocmds_to_buffer(augroup, bufnr, autocmds)
  if not vim.islist(autocmds) then
    autocmds = { autocmds }
  end

  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })

  if not cmds_found or vim.tbl_isempty(cmds) then
    vim.api.nvim_create_augroup(augroup, { clear = false })

    for _, autocmd in ipairs(autocmds) do
      local events = autocmd.events
      autocmd.events = nil
      autocmd.group = augroup
      autocmd.buffer = bufnr
      vim.api.nvim_create_autocmd(events, autocmd)
    end
  end
end

function M.without_animation(func)
  vim.g.minianimate_disable = true
  local result = func()
  vim.g.minianimate_disable = false
  return result
end

function M.get_mappings_template()
  local maps = {}
  for _, mode in ipairs {
    '',
    'n',
    'v',
    'x',
    's',
    'o',
    '!',
    'i',
    'l',
    'c',
    't',
    'ia',
    'ca',
    '!a',
  } do
    maps[mode] = {}
  end
  return maps
end

function M.set_mappings(map_table, base)
  for mode, maps in pairs(map_table) do
    for keymap, options in pairs(maps) do
      if options then
        local cmd
        local keymap_opts = base or {}
        if type(options) == 'string' or type(options) ==
            'function' then
          cmd = options
        else
          cmd = options[1]
          keymap_opts = vim.tbl_deep_extend('force',
            keymap_opts, options)
          keymap_opts[1] = nil
        end
        if cmd then
          vim.keymap.set(mode, keymap, cmd, keymap_opts)
        end
      end
    end
  end
end

function M.get_plugin_opts(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  local lazy_plugin_avail, lazy_plugin = pcall(require, 'lazy.core.plugin')
  local opts = {}

  if lazy_config_avail and lazy_plugin_avail then
    local spec = lazy_config.spec.plugins[plugin]
    if spec then
      opts = lazy_plugin.values(spec, 'opts')
    end
  end

  return opts
end

function M.get_icon(icon_name)
  local icon_pack = 'icons'

  if not M[icon_pack] then
    if icon_pack == 'icons' then
      M.icons = require('sylow.utils.icons')
    end
  end

  local icon = M[icon_pack] and M[icon_pack][icon_name] or ''
  return icon
end

function M.notify(msg, level, opts)
  vim.schedule(function()
    vim.notify(msg, level, vim.tbl_deep_extend('force', { title = 'Notify' }, opts or {}))
  end)
end

function M.is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
end

function M.is_big_file(bufnr)
  bufnr = bufnr or 0

  local filesize = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
  local nlines = vim.api.nvim_buf_line_count(bufnr)

  return (filesize > vim.g.big_file.size) or (nlines > vim.g.big_file.lines)
end

function M.os_path(path)
  if path == nil then return nil end
  -- Get the platform-specific path separator
  local separator = string.sub(package.config, 1, 1)
  return string.gsub(path, '[/\\]', separator)
end

function M.get_all_files()
  local config_dir = M.os_path(vim.fn.stdpath("config") .. "/lua/sylow/")
  local files = {}

  local function scan_dir(dir)
    local items = vim.fn.readdir(dir)
    for _, item in ipairs(items) do
      local path = dir .. "/" .. item
      if vim.fn.isdirectory(path) == 1 then
        scan_dir(path) -- Recurse into subdirectories
      else
        table.insert(files, path)
      end
    end
  end

  scan_dir(config_dir)
  return files
end

------------------------------------------
-- UI Display Utilities
------------------------------------------


function M.clear_search()
  if vim.fn.hlexists('Search') then
    vim.cmd('nohlsearch')
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, true, true), 'n', true)
  end
end

return M
