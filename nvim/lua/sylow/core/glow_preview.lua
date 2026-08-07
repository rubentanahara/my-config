-- Auto-preview the current markdown buffer in a reused vertical glow split.
local M = {}

local api = vim.api
local win, buf, job, current_file
local debounce_gen = 0
M.persist = false -- when true, leaving a markdown buffer leaves the preview open

local function is_md(bufnr)
  return vim.bo[bufnr].filetype == 'markdown'
end

local function close_preview()
  if job then
    pcall(vim.fn.jobstop, job)
    job = nil
  end
  if win and api.nvim_win_is_valid(win) then
    pcall(api.nvim_win_close, win, true)
  end
  win, buf, current_file = nil, nil, nil
end

local function render(file)
  if job then
    pcall(vim.fn.jobstop, job)
    job = nil
  end

  if not (win and api.nvim_win_is_valid(win)) then
    local cur_win = api.nvim_get_current_win()
    vim.cmd('botright vsplit')
    win = api.nvim_get_current_win()
    api.nvim_set_current_win(cur_win)
  end

  -- termopen refuses to reuse a buffer with prior (modified) glow output,
  -- so give every render a fresh scratch buffer; bufhidden=wipe cleans the old one up.
  buf = api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  api.nvim_win_set_buf(win, buf)

  current_file = file
  api.nvim_win_call(win, function()
    local width = math.max(api.nvim_win_get_width(win) - 2, 20)
    job = vim.fn.termopen({ 'glow', '-w', tostring(width), file })
  end)
end

-- Show/switch/hide the preview based on the buffer that just became current.
function M.on_buf_enter(bufnr)
  if buf and bufnr == buf then
    return -- entering the glow window itself, leave it alone
  end

  if not is_md(bufnr) then
    if not M.persist then
      close_preview()
    end
    return
  end

  local file = api.nvim_buf_get_name(bufnr)
  if file == '' then
    close_preview()
    return
  end

  if file == current_file and win and api.nvim_win_is_valid(win) then
    return
  end

  render(file)
end

-- Re-render on save, debounced (formatters/plugins can fire multiple writes).
function M.on_write(bufnr)
  if not is_md(bufnr) then
    return
  end
  local file = api.nvim_buf_get_name(bufnr)
  if file ~= current_file then
    return
  end

  debounce_gen = debounce_gen + 1
  local gen = debounce_gen
  vim.defer_fn(function()
    if gen == debounce_gen then
      render(file)
    end
  end, 200)
end

function M.toggle_persist()
  M.persist = not M.persist
  vim.notify('glow preview persist: ' .. tostring(M.persist), vim.log.levels.INFO)
  M.on_buf_enter(api.nvim_get_current_buf())
end

return M
