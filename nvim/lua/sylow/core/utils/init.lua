local M = {}

------------------------------------------
-- System Operations
------------------------------------------

function M.run_cmd(cmd, show_error)
  -- Split cmd string into a list, if needed.
  if type(cmd) == 'string' then
    cmd = vim.split(cmd, ' ')
  end

  -- If windows, and prepend cmd.exe
  if vim.fn.has('win32') == 1 then
    cmd = vim.list_extend({ 'cmd.exe', '/C' }, cmd)
  end

  -- Execute cmd and store result (output or error message)
  local result = vim.fn.system(cmd)
  local success = vim.api.nvim_get_vvar('shell_error') == 0

  -- If the command failed and show_error is true or not provided, print error.
  if not success and (show_error == nil or show_error) then
    vim.api.nvim_echo({
      {
        ('Error running command %s\nError message:\n%s'):format(
          table.concat(cmd, ' '), -- Convert the cmd back to string.
          result -- Show the error result
        ),
      },
    }, true, { err = true })
  end

  -- strip out terminal escape sequences and control characters.
  local cleaned_result = result:gsub('[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]', '')

  -- Return cleaned result on success, nil on failure
  return success and cleaned_result or nil
end

function M.os_path(path)
  if path == nil then
    return nil
  end

  local separator = string.sub(package.config, 1, 1)
  return string.gsub(path, '[/\\]', separator)
end

function M.open_with_program(path)
  -- Use vim.ui.open if available
  if vim.ui.open then
    return vim.ui.open(path)
  end

  -- Determine appropriate command based on OS
  local cmd
  if vim.fn.has('mac') == 1 then
    cmd = { 'open' }
  elseif vim.fn.has('win32') == 1 then
    if vim.fn.executable('rundll32') then
      cmd = { 'rundll32', 'url.dll,FileProtocolHandler' }
    else
      cmd = { 'cmd.exe', '/K', 'explorer' }
    end
  elseif vim.fn.has('unix') == 1 then
    if vim.fn.executable('explorer.exe') == 1 then -- WSL
      cmd = { 'explorer.exe' }
    elseif vim.fn.executable('xdg-open') == 1 then
      cmd = { 'xdg-open' }
    end
  end

  if not cmd then
    M.notify('Available system opening tool not found!', vim.log.levels.ERROR)
    return
  end

  -- Resolve path
  if not path then
    path = vim.fn.expand('<cfile>')
  elseif not path:match('%w+:') then
    path = vim.fn.expand(path)
  end

  -- Launch process detached
  vim.fn.jobstart(vim.list_extend(cmd, { path }), { detach = true })
end

------------------------------------------
-- Autocommand Utilities
------------------------------------------

function M.add_autocmds_to_buffer(augroup, bufnr, autocmds)
  -- Ensure autocmds is a list
  if not vim.islist(autocmds) then
    autocmds = { autocmds }
  end

  -- Check if autocommands already exist
  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })

  -- Only add if no existing autocommands were found
  if not cmds_found or vim.tbl_isempty(cmds) then
    -- Create augroup if it doesn't exist
    vim.api.nvim_create_augroup(augroup, { clear = false })

    -- Add each autocommand
    for _, autocmd in ipairs(autocmds) do
      local events = autocmd.events
      autocmd.events = nil
      autocmd.group = augroup
      autocmd.buffer = bufnr
      vim.api.nvim_create_autocmd(events, autocmd)
    end
  end
end

function M.del_autocmds_from_buffer(augroup, bufnr)
  local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })

  if cmds_found then
    vim.tbl_map(function(cmd)
      vim.api.nvim_del_autocmd(cmd.id)
    end, cmds)
  end
end

function M.trigger_event(event, is_urgent)
  local function trigger()
    local is_user_event = string.match(event, '^User ') ~= nil
    if is_user_event then
      event = event:gsub('^User ', '')
      vim.api.nvim_exec_autocmds('User', { pattern = event, modeline = false })
    else
      vim.api.nvim_exec_autocmds(event, { modeline = false })
    end
  end

  if is_urgent then
    trigger()
  else
    vim.schedule(trigger)
  end
end

------------------------------------------
-- Icons and UI Utilities
------------------------------------------

function M.get_icon(icon_name, fallback_to_empty)
  local icon_pack = 'icons'

  -- Load icon pack if not cached
  if not M[icon_pack] then
    if icon_pack == 'icons' then
      M.icons = require('sylow.core.icons.icons')
    end
  end

  -- Return the icon
  local icon = M[icon_pack] and M[icon_pack][icon_name] or ''
  return icon
end

------------------------------------------
-- Keymapping Utilities
------------------------------------------

--- Create an empty mappings template for all modes
--- @return table<string,table> mappings Empty mappings table
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
  -- iterate over the first keys for each mode
  for mode, maps in pairs(map_table) do
    -- iterate over each keybinding set in the current mode
    for keymap, options in pairs(maps) do
      -- build the options for the command accordingly
      if options then
        local cmd
        local keymap_opts = base or {}
        if type(options) == 'string' or type(options) == 'function' then
          cmd = options
        else
          cmd = options[1]
          keymap_opts = vim.tbl_deep_extend('force', keymap_opts, options)
          keymap_opts[1] = nil
        end
        if not cmd then -- if which-key mapping, queue it
          keymap_opts[1], keymap_opts.mode = keymap, mode
          if not keymap_opts.group then
            keymap_opts.group = keymap_opts.desc
          end
          if not M.which_key_queue then
            M.which_key_queue = {}
          end
          table.insert(M.which_key_queue, keymap_opts)
        else -- if not which-key mapping, set it
          vim.keymap.set(mode, keymap, cmd, keymap_opts)
        end
      end
    end
  end
  -- if which-key is loaded already, register
  if package.loaded['which-key'] then
    M.which_key_register()
  end
end

--- Add syntax highlighting for URLs/URIs
function M.set_url_effect()
  -- URL matching regex pattern
  local url_matcher = '\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)'
    .. '%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)'
    .. '[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|'
    .. '[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)'
    .. '|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*'
    .. '|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+'

  -- Clear existing URL highlighting
  M.delete_url_effect()

  -- Apply highlighting if enabled
  if vim.g.url_effect_enabled then
    vim.fn.matchadd('HighlightURL', url_matcher, 15)
  end
end

--- Remove URL/URI syntax highlighting
function M.delete_url_effect()
  for _, match in ipairs(vim.fn.getmatches()) do
    if match.group == 'HighlightURL' then
      vim.fn.matchdelete(match.id)
    end
  end
end

------------------------------------------
-- Notifications
------------------------------------------

function M.notify(msg, level, opts)
  vim.schedule(function()
    vim.notify(msg, level, vim.tbl_deep_extend('force', { title = 'Neovim' }, opts or {}))
  end)
end

------------------------------------------
-- Plugin Management
------------------------------------------

function M.is_available(plugin)
  local lazy_config_avail, lazy_config = pcall(require, 'lazy.core.config')
  return lazy_config_avail and lazy_config.spec.plugins[plugin] ~= nil
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

------------------------------------------
-- File Operations
------------------------------------------

function M.is_big_file(bufnr)
  bufnr = bufnr or 0

  local filesize = vim.fn.getfsize(vim.api.nvim_buf_get_name(bufnr))
  local nlines = vim.api.nvim_buf_line_count(bufnr)

  return (filesize > vim.g.big_file.size) or (nlines > vim.g.big_file.lines)
end

--- Register queued which-key mappings.
function M.which_key_register()
  if M.which_key_queue then
    local wk_avail, wk = pcall(require, 'which-key')
    if wk_avail then
      wk.add(M.which_key_queue)
      M.which_key_queue = nil
    end
  end
end

return M
