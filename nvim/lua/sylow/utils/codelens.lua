-- Column-0 code lens renderer.
--
-- Neovim 0.12's built-in `vim.lsp.codelens` indents each lens to the symbol's
-- start column (runtime/lua/vim/lsp/codelens.lua:242 pads with
-- `string.rep(' ', range.start_col)`), so Roslyn's "0 references" sits under the
-- class/method name instead of at the start of the line. There is no option to
-- change that, and the old `vim.lsp.codelens.display` override is a deprecated
-- no-op in 0.12.
--
-- This module reimplements the request -> resolve -> render pipeline and pins
-- every lens to column 0. It is fully independent of `vim.lsp.codelens.enable()`,
-- so the two must never run on the same buffer at once or lenses render twice.

local util = require('vim.lsp.util')
local api = vim.api

local M = {}

local ns = api.nvim_create_namespace('sylow.codelens')
local timers = {} ---@type table<integer, uv.uv_timer_t> per-buffer debounce
local request_seq = {} ---@type table<integer, integer> drop stale responses
local enabled_bufs = {} ---@type table<integer, true>
local handler_installed = false

local function clear(bufnr)
  if api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  end
end

local function codelens_clients(bufnr)
  return vim.tbl_filter(function(client)
    return client:supports_method('textDocument/codeLens', { bufnr = bufnr })
  end, vim.lsp.get_clients({ bufnr = bufnr }))
end

-- Draw resolved lenses (those with a `.command`) as a virtual line at column 0.
local function render(bufnr, lenses)
  clear(bufnr)
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end

  local by_row = {}
  for _, lens in ipairs(lenses) do
    if lens.command and lens.command.title then
      local row = lens.range.start.line
      by_row[row] = by_row[row] or {}
      table.insert(by_row[row], lens)
    end
  end

  for row, row_lenses in pairs(by_row) do
    table.sort(row_lenses, function(a, b)
      return a.range.start.character < b.range.start.character
    end)
    local chunks = {}
    for _, lens in ipairs(row_lenses) do
      if #chunks > 0 then
        table.insert(chunks, { ' | ', 'LspCodeLensSeparator' })
      end
      table.insert(chunks, { lens.command.title, 'LspCodeLens' })
    end
    -- Align the lens under the first non-whitespace character of the line
    -- (its indentation), rather than the symbol column (native) or column 0.
    local line = api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
    local indent = line:match('^%s*')
    if #indent > 0 then
      table.insert(chunks, 1, { indent, 'LspCodeLensSeparator' })
    end
    pcall(api.nvim_buf_set_extmark, bufnr, ns, row, 0, {
      virt_lines = { chunks },
      virt_lines_above = true,
      hl_mode = 'combine',
    })
  end
end

-- Request lenses from every codeLens-capable client, resolve any that arrive
-- unresolved, then render once. A monotonic per-buffer token drops responses
-- superseded by a newer refresh.
function M.refresh(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end
  local clients = codelens_clients(bufnr)
  if #clients == 0 then
    clear(bufnr)
    return
  end

  request_seq[bufnr] = (request_seq[bufnr] or 0) + 1
  local seq = request_seq[bufnr]
  local params = { textDocument = util.make_text_document_params(bufnr) }

  local collected = {}
  local pending = #clients

  local function finish()
    if request_seq[bufnr] ~= seq then
      return -- a newer refresh superseded this one
    end
    local to_resolve = vim.tbl_filter(function(item)
      return item.lens.command == nil
    end, collected)

    local function draw()
      if request_seq[bufnr] == seq then
        render(bufnr, vim.tbl_map(function(item)
          return item.lens
        end, collected))
      end
    end

    if #to_resolve == 0 then
      draw()
      return
    end
    local pending_resolve = #to_resolve
    for _, item in ipairs(to_resolve) do
      item.client:request('codeLens/resolve', item.lens, function(_, resolved)
        if resolved then
          item.lens = resolved
        end
        pending_resolve = pending_resolve - 1
        if pending_resolve == 0 then
          draw()
        end
      end, bufnr)
    end
  end

  for _, client in ipairs(clients) do
    client:request('textDocument/codeLens', params, function(err, result)
      if not err and result then
        for _, lens in ipairs(result) do
          table.insert(collected, { client = client, lens = lens })
        end
      end
      pending = pending - 1
      if pending == 0 then
        finish()
      end
    end, bufnr)
  end
end

function M.refresh_debounced(bufnr, delay)
  bufnr = bufnr or api.nvim_get_current_buf()
  delay = delay or 200
  local timer = timers[bufnr]
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
  end
  timers[bufnr] = vim.defer_fn(function()
    timers[bufnr] = nil
    M.refresh(bufnr)
  end, delay)
end

-- Server-pushed refresh (Roslyn fires this when reference counts change).
local function install_handler()
  if handler_installed then
    return
  end
  handler_installed = true
  vim.lsp.handlers['workspace/codeLens/refresh'] = function(_, _, _)
    for bufnr in pairs(enabled_bufs) do
      if api.nvim_buf_is_valid(bufnr) and vim.g.codelens_enabled then
        M.refresh_debounced(bufnr)
      end
    end
    return vim.NIL
  end
end

-- Attach refresh autocmds to a buffer. Safe to call on every LspAttach.
function M.attach(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  install_handler()
  if not enabled_bufs[bufnr] then
    enabled_bufs[bufnr] = true
    local group = api.nvim_create_augroup('sylow_codelens_' .. bufnr, { clear = true })
    api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'TextChanged' }, {
      group = group,
      buffer = bufnr,
      callback = function()
        if vim.g.codelens_enabled then
          M.refresh_debounced(bufnr)
        end
      end,
    })
    api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
      group = group,
      buffer = bufnr,
      callback = function()
        M.detach(bufnr)
      end,
    })
  end
  if vim.g.codelens_enabled then
    M.refresh(bufnr)
  end
end

function M.detach(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  enabled_bufs[bufnr] = nil
  request_seq[bufnr] = nil
  pcall(api.nvim_del_augroup_by_name, 'sylow_codelens_' .. bufnr)
  clear(bufnr)
end

-- Render/clear every managed buffer to follow the global `vim.g.codelens_enabled`.
function M.sync_all()
  for bufnr in pairs(enabled_bufs) do
    if api.nvim_buf_is_valid(bufnr) then
      if vim.g.codelens_enabled then
        M.refresh(bufnr)
      else
        clear(bufnr)
      end
    end
  end
end

-- Run the code lens at the cursor (mirrors vim.lsp.codelens.run).
function M.run(opts)
  opts = opts or {}
  local winid = api.nvim_get_current_win()
  local bufnr = api.nvim_win_get_buf(winid)
  local lnum = api.nvim_win_get_cursor(winid)[1] - 1
  local params = { textDocument = util.make_text_document_params(bufnr) }
  vim.lsp.buf_request_all(bufnr, 'textDocument/codeLens', params, function(results)
    local candidates = {}
    local pending = 1
    local function done()
      pending = pending - 1
      if pending > 0 then
        return
      end
      if #candidates == 0 then
        vim.notify('No codelens at current line')
      elseif #candidates == 1 then
        candidates[1].client:exec_cmd(candidates[1].lens.command, { bufnr = bufnr })
      else
        vim.ui.select(candidates, {
          prompt = 'Code lenses: ',
          kind = 'codelens',
          format_item = function(c)
            return string.format('%s [%s]', c.lens.command.title, c.client.name)
          end,
        }, function(c)
          if c then
            c.client:exec_cmd(c.lens.command, { bufnr = bufnr })
          end
        end)
      end
    end
    for client_id, res in pairs(results) do
      if opts.client_id == nil or opts.client_id == client_id then
        local client = vim.lsp.get_client_by_id(client_id)
        for _, lens in ipairs(res.result or {}) do
          if lens.range.start.line == lnum then
            if lens.command then
              table.insert(candidates, { client = client, lens = lens })
            else
              pending = pending + 1
              client:request('codeLens/resolve', lens, function(_, resolved)
                if resolved then
                  table.insert(candidates, { client = client, lens = resolved })
                end
                done()
              end, bufnr)
            end
          end
        end
      end
    end
    done()
  end)
end

return M
