local M = {}

--- Local reference to vim API functions for performance
local api = vim.api
local fn = vim.fn
local opt_local = vim.opt_local
local bo = vim.bo

local function create_augroup(name)
  return api.nvim_create_augroup('sylow_' .. name, { clear = true })
end

local function create_autocmd(event, opts)
  opts.group = opts.group or create_augroup(opts.desc:gsub('%s+', '_'):lower())
  return api.nvim_create_autocmd(event, opts)
end

local function create_user_command(name, fn, opts)
  return api.nvim_create_user_command(name, fn, opts)
end

local options = {
  -- Filetypes to enable spell checking and wrapping
  text_filetypes = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  -- Filetypes to exclude from view saving
  view_ignore_filetypes = { 'gitcommit', 'gitrebase', 'svg', 'hgcommit' },
  -- Filetypes to close with q
  close_with_q_filetypes = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'man',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  -- Filetypes to unlist from buffer list
  unlist_filetypes = { 'man', 'help' },
}

local function setup_filetype_autocmds()
  -- JSON files conceallevel
  create_autocmd('FileType', {
    desc = 'Fix conceallevel for JSON files',
    pattern = { 'json', 'jsonc', 'json5' },
    callback = function()
      opt_local.conceallevel = 0
    end,
  })

  -- Text file settings
  create_autocmd('FileType', {
    desc = 'Enable wrapping and spell checking in text filetypes',
    pattern = options.text_filetypes,
    callback = function()
      opt_local.wrap = true
      opt_local.spell = true
    end,
  })

  -- Quickfix and help settings - close with q
  create_autocmd('FileType', {
    desc = 'Make certain filetypes closable with q and unlist them',
    pattern = options.close_with_q_filetypes,
    callback = function(event)
      bo[event.buf].buflisted = false
      vim.keymap.set('n', 'q', function()
        vim.cmd('close')
        pcall(api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end,
  })

  -- Unlist specific buffer types
  create_autocmd('FileType', {
    desc = 'Unlist specific buffer types from buffer list',
    pattern = options.unlist_filetypes,
    callback = function(event)
      bo[event.buf].buflisted = false
    end,
  })

  return true
end

local function setup_buffer_autocmds()
  -- File change detection
  create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
    desc = 'Check if files need to be reloaded when changed externally',
    callback = function()
      if vim.o.buftype ~= 'nofile' then
        vim.cmd('checktime')
      end
    end,
  })

  -- View saving
  create_autocmd({ 'BufWinLeave', 'BufWritePost', 'WinLeave' }, {
    desc = 'Save view with mkview for real files',
    callback = function(args)
      if vim.b[args.buf].view_activated then
        vim.cmd.mkview { mods = { emsg_silent = true } }
      end
    end,
  })

  -- View loading
  create_autocmd('BufWinEnter', {
    desc = 'Load view if available and enable view saving for real files',
    callback = function(args)
      if not vim.b[args.buf].view_activated then
        local filetype = api.nvim_get_option_value('filetype', { buf = args.buf })
        local buftype = api.nvim_get_option_value('buftype', { buf = args.buf })
        if
          buftype == ''
          and filetype
          and filetype ~= ''
          and not vim.tbl_contains(options.view_ignore_filetypes, filetype)
        then
          vim.b[args.buf].view_activated = true
          vim.cmd.loadview { mods = { emsg_silent = true } }
        end
      end
    end,
  })

  -- Go to last location when opening a buffer
  create_autocmd('BufReadPost', {
    desc = 'Return to last position in file',
    callback = function(event)
      local buf = event.buf
      if vim.tbl_contains(options.view_ignore_filetypes, vim.bo[buf].filetype) or vim.b[buf].last_position_jump then
        return
      end

      vim.b[buf].last_position_jump = true
      local mark = api.nvim_buf_get_mark(buf, '"')
      local line_count = api.nvim_buf_line_count(buf)
      if mark[1] > 0 and mark[1] <= line_count then
        pcall(api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })

  -- Create parent directories when saving a file
  create_autocmd('BufWritePre', {
    desc = "Create parent directories when saving a file if they don't exist",
    callback = function(event)
      if event.match:match('^%w%w+:[\\/][\\/]') then
        return
      end

      local file = vim.uv.fs_realpath(event.match) or event.match
      fn.mkdir(fn.fnamemodify(file, ':p:h'), 'p')
    end,
  })

  return true
end

local function setup_ui_autocmds()
  -- URL Highlighting
  api.nvim_set_hl(0, 'HighlightURL', { underline = true })

  -- Highlight on yank
  create_autocmd('TextYankPost', {
    desc = 'Highlight text on yank',
    callback = function()
      (vim.hl or vim.highlight).on_yank()
    end,
  })

  -- Window resizing
  create_autocmd('VimResized', {
    desc = 'Equalize window sizes when terminal is resized',
    callback = function()
      local current_tab = fn.tabpagenr()
      vim.cmd('tabdo wincmd =')
      vim.cmd('tabnext ' .. current_tab)
    end,
  })

  -- Terminal behavior
  create_autocmd('TermOpen', {
    desc = 'Set terminal buffer options',
    callback = function()
      opt_local.number = false
      opt_local.relativenumber = false
      opt_local.signcolumn = 'no'
      opt_local.spell = false
      vim.cmd('startinsert')
    end,
  })

  -- Terminal exit
  create_autocmd('BufLeave', {
    desc = 'Close terminal buffer on process exit',
    pattern = 'term://*',
    callback = function()
      vim.cmd('stopinsert')
    end,
  })

  -- Cursor line highlighting in active window only
  -- create_autocmd({ 'InsertLeave', 'WinEnter' }, {
  --   desc = 'Enable cursor line in active window',
  --   callback = function()
  --     if vim.bo.buftype == '' then
  --       opt_local.cursorline = true
  --     end
  --   end,
  -- })

  create_autocmd({ 'InsertEnter', 'WinLeave' }, {
    desc = 'Disable cursor line in inactive windows',
    callback = function()
      if vim.bo.buftype == '' then
        opt_local.cursorline = false
      end
    end,
  })

  return true
end

-- local function setup_lsp_autocmds()
--   create_autocmd('LspAttach', {
--     desc = 'On lsp attach',
--     callback = function(e)
--       local opts = { buffer = e.buf }
--       vim.keymap.set('n', 'gd', function()
--         vim.lsp.buf.definition()
--       end, opts)
--     end,
--   })
--
--   return true
-- end

local function setup_diagnostic_autocmds()
  -- Update diagnostics in insert mode (disabled by default)
  create_autocmd('DiagnosticChanged', {
    desc = 'Update diagnostics when changed',
    callback = function()
      if not vim.diagnostic.is_enabled() or vim.api.nvim_get_mode().mode:match('i') then
        return
      end
      vim.diagnostic.setloclist({ open = false })
    end,
  })

  return true
end

function M.setup()
  local success = true

  local isOkFileTypeAutocmds = setup_filetype_autocmds()
  if not isOkFileTypeAutocmds then
    vim.notify('Failed to setup_filetype_autocmds', vim.log.levels.ERROR)
  end

  local isOkBufferAutoCmds = setup_buffer_autocmds()
  if not isOkBufferAutoCmds then
    vim.notify('Failed to setup_buffer_autocmds ', vim.log.levels.ERROR)
  end

  local isOkUIAutocmds = setup_ui_autocmds()
  if not isOkUIAutocmds then
    vim.notify('Failed to setup_buffer_autocmds', vim.log.levels.ERROR)
  end

  -- local isOkLspAutocmds = setup_lsp_autocmds()
  -- if not isOkLspAutocmds then
  --   vim.notify('Failed to setup_lsp_autocmds', vim.log.levels.ERROR)
  -- end

  local isOkDiagnosticAutocmds = setup_diagnostic_autocmds()
  if not isOkDiagnosticAutocmds then
    vim.notify('Failed to setup_diagnostic_autocmds', vim.log.levels.ERROR)
  end

  return success
end

return M
