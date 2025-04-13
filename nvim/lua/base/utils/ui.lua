local M = {}
local utils = require("base.utils")
local function bool2str(bool) return bool and "on" or "off" end
local _vim = vim
local opt = _vim.opt
local g = _vim.g
local go = _vim.go
local wo = _vim.wo
local bo = _vim.bo
local b = _vim.b
local cmd = _vim.cmd
local fn = _vim.fn
local api = _vim.api
local lsp = _vim.lsp
local utils_lsp = require("base.utils.lsp")
local lsp_signature = require("lsp_signature")
local treesitter = require("nvim-treesitter.parsers")

--- Change the number display modes
function M.change_number()
  local number = wo.number                 -- local to window
  local relativenumber = wo.relativenumber -- local to window
  if not number and not relativenumber then
    wo.number = true
  elseif number and not relativenumber then
    wo.relativenumber = true
  elseif number and relativenumber then
    wo.number = false
  else -- not number and relativenumber
    wo.relativenumber = false
  end
  utils.notify(string.format("number %s, relativenumber %s", bool2str(wo.number), bool2str(wo.relativenumber)),
    _vim.log.levels.INFO)
end

--- Set the indent and tab related numbers
function M.set_indent()
  local input_avail, input = pcall(fn.input, "Set indent value (>0 expandtab, <=0 noexpandtab): ")
  if input_avail then
    local indent = tonumber(input)
    if not indent or indent == 0 then return end
    bo.expandtab = (indent > 0) -- local to buffer
    indent = math.abs(indent)
    bo.tabstop = indent         -- local to buffer
    bo.softtabstop = indent     -- local to buffer
    bo.shiftwidth = indent      -- local to buffer
    utils.notify(string.format("indent=%d %s", indent, bo.expandtab and "expandtab" or "noexpandtab"),
      _vim.log.levels.INFO)
  end
end

--- Toggle animations
function M.toggle_animations()
  if g.minianimate_disable then
    g.minianimate_disable = false
  else
    g.minianimate_disable = true
  end

  local state = g.minianimate_disable
  utils.notify(string.format("animations %s", bool2str(not state)), _vim.log.levels.INFO)
end

--- Toggle auto format
function M.toggle_autoformat()
  g.autoformat_enabled = not g.autoformat_enabled
  utils.notify(string.format("Global autoformatting %s", bool2str(g.autoformat_enabled)), _vim.log.levels.INFO)
end

--- Toggle autopairs
function M.toggle_autopairs()
  local ok, autopairs = pcall(require, "nvim-autopairs")
  if ok then
    if autopairs.state.disabled then
      autopairs.enable()
    else
      autopairs.disable()
    end
    g.autopairs_enabled = autopairs.state.disabled
    utils.notify(string.format("autopairs %s", bool2str(not autopairs.state.disabled)), _vim.log.levels.INFO)
  else
    utils.notify("autopairs not available", _vim.log.levels.ERROR)
  end
end

--- Toggle background="dark"|"light"
function M.toggle_background()
  go.background = go.background == "light" and "dark" or "light"
  utils.notify(string.format("background=%s", go.background), _vim.log.levels.INFO)
end

--- Toggle buffer local auto format
--- @param bufnr? number the buffer to toggle `autoformat` on.
function M.toggle_buffer_autoformat(bufnr)
  bufnr = bufnr or 0
  local old_val = b[bufnr].autoformat_enabled
  if old_val == nil then old_val = g.autoformat_enabled end
  b[bufnr].autoformat_enabled = not old_val
  utils.notify(string.format("Buffer autoformatting %s", bool2str(b[bufnr].autoformat_enabled)), _vim.log.levels.INFO)
end

--- Toggle LSP inlay hints (buffer)
--- @param bufnr? number the buffer to toggle the `inlay hints` on.
function M.toggle_buffer_inlay_hints(bufnr)
  bufnr = bufnr or 0
  b[bufnr].inlay_hints_enabled = not b[bufnr].inlay_hints_enabled
  lsp.inlay_hint.enable(b[bufnr].inlay_hints_enabled, { bufnr = bufnr })
  utils.notify(string.format("Buffer inlay hints %s", bool2str(b[bufnr].inlay_hints_enabled)), _vim.log.levels.INFO)
end

--- Toggle buffer semantic token highlighting for all language servers that support it
--- @param bufnr? number the buffer to toggle `semantic tokens` on.
function M.toggle_buffer_semantic_tokens(bufnr)
  bufnr = bufnr or 0
  b[bufnr].semantic_tokens_enabled = not b[bufnr].semantic_tokens_enabled
  for _, client in ipairs(lsp.get_clients({ bufnr = bufnr })) do
    if client.server_capabilities.semanticTokensProvider then
      lsp.semantic_tokens[b[bufnr].semantic_tokens_enabled and "start" or "stop"](bufnr, client.id)
      utils.notify(string.format("Buffer lsp semantic highlighting %s", bool2str(b[bufnr].semantic_tokens_enabled)),
        _vim.log.levels.INFO)
    end
  end
end

--- Toggle syntax highlighting and treesitter
--- @param bufnr? number the buffer to toggle `treesitter` on.
function M.toggle_buffer_syntax(bufnr)
  -- HACK: this should just be `bufnr = bufnr or 0` but it looks like
  --       `vim.treesitter.stop` has a bug with `0` being current.
  bufnr = (bufnr and bufnr ~= 0) and bufnr or api.nvim_win_get_buf(0)
  local ts_avail, parsers = pcall(require, "nvim-treesitter.parsers")
  if bo[bufnr].syntax == "off" then
    if ts_avail and parsers.has_parser() then treesitter.start(bufnr) end
    bo[bufnr].syntax = "on"
    if not b.semantic_tokens_enabled then M.toggle_buffer_semantic_tokens(bufnr) end
  else
    if ts_avail and parsers.has_parser() then treesitter.stop(bufnr) end
    bo[bufnr].syntax = "off"
    if b.semantic_tokens_enabled then M.toggle_buffer_semantic_tokens(bufnr) end
  end
  utils.notify(string.format("syntax %s", bool2str(bo[bufnr].syntax)), _vim.log.levels.INFO)
end

--- Toggle codelens
--- @param bufnr? number the buffer to toggle `codelens` on.
function M.toggle_codelens(bufnr)
  bufnr = bufnr or 0
  g.codelens_enabled = not g.codelens_enabled
  if g.codelens_enabled then
    lsp.codelens.refresh({ bufnr = bufnr })
  else
    lsp.codelens.clear()
  end
  utils.notify(string.format("CodeLens %s", bool2str(g.codelens_enabled)), _vim.log.levels.INFO)
end

--- Toggle coverage signs
--- @param bufnr? number the buffer to toggle `coverage signs` on.
function M.toggle_coverage_signs(bufnr)
  bufnr = bufnr or 0
  b[bufnr].coverage_signs_enabled = not b[bufnr].coverage_signs_enabled
  if b[bufnr].coverage_signs_enabled then
    utils.notify("Coverage signs on:" ..
      "\n\n- Git signs will be temporary disabled." ..
      "\n- Diagnostic signs won't be automatically disabled.", _vim.log.levels.INFO)
    cmd("Gitsigns toggle_signs")
    require("coverage").load(true)
  else
    utils.notify("Coverage signs off:\n\n- Git signs re-enabled.", _vim.log.levels.INFO)
    require("coverage").hide()
    cmd("Gitsigns toggle_signs")
  end
end

--- Toggle cmp entrirely
function M.toggle_cmp()
  g.cmp_enabled = not g.cmp_enabled
  local ok, _ = pcall(require, "cmp")
  utils.notify(ok and string.format("completion %s", bool2str(g.cmp_enabled)) or "completion not available",
    _vim.log.levels.INFO)
end

--- Toggle conceal=2|0
function M.toggle_conceal()
  opt.conceallevel = opt.conceallevel:get() == 0 and 2 or 0
  utils.notify(string.format("conceal %s", bool2str(opt.conceallevel:get() == 2)), _vim.log.levels.INFO)
end

--- Toggle diagnostics
function M.toggle_diagnostics()
  g.diagnostics_mode = (g.diagnostics_mode - 1) % 4
  _vim.diagnostic.config(utils_lsp.diagnostics[g.diagnostics_mode])
  if g.diagnostics_mode == 0 then
    utils.notify("diagnostics off", _vim.log.levels.INFO)
  elseif g.diagnostics_mode == 1 then
    utils.notify("status line only", _vim.log.levels.INFO)
  elseif g.diagnostics_mode == 2 then
    utils.notify("virtual text off, signs on", _vim.log.levels.INFO)
  else
    utils.notify("all diagnostics on", _vim.log.levels.INFO)
  end
end

local last_active_foldcolumn
--- Toggle foldcolumn=0|1
function M.toggle_foldcolumn()
  local curr_foldcolumn = wo.foldcolumn
  if curr_foldcolumn ~= "0" then last_active_foldcolumn = curr_foldcolumn end
  wo.foldcolumn = curr_foldcolumn == "0" and (last_active_foldcolumn or "1") or "0"
  utils.notify(string.format("foldcolumn=%s", wo.foldcolumn), _vim.log.levels.INFO)
end

--- Toggle LSP inlay hints (global)
--- @param bufnr? number the buffer to toggle the `inlay_hints` on.
function M.toggle_inlay_hints(bufnr)
  bufnr = bufnr or 0
  g.inlay_hints_enabled = not g.inlay_hints_enabled                   -- flip global state
  b.inlay_hints_enabled = not g.inlay_hints_enabled                   -- sync buffer state
  lsp.buf.inlay_hint.enable(g.inlay_hints_enabled, { bufnr = bufnr }) -- apply state
  utils.notify(string.format("Global inlay hints %s", bool2str(g.inlay_hints_enabled)), _vim.log.levels.INFO)
end

--- Toggle lsp signature
function M.toggle_lsp_signature()
  local state = lsp_signature.toggle_float_win()
  utils.notify(string.format("lsp signature %s", bool2str(state)), _vim.log.levels.INFO)
end

--- Toggle paste
function M.toggle_paste()
  opt.paste = not opt.paste:get() -- local to window
  utils.notify(string.format("paste %s", bool2str(opt.paste:get())), _vim.log.levels.INFO)
end

--- Toggle signcolumn="auto"|"no"
function M.toggle_signcolumn()
  if wo.signcolumn == "no" then
    wo.signcolumn = "yes"
  elseif wo.signcolumn == "yes" then
    wo.signcolumn = "auto"
  else
    wo.signcolumn = "no"
  end
  utils.notify(string.format("signcolumn=%s", wo.signcolumn), _vim.log.levels.INFO)
end

--- Toggle spell
function M.toggle_spell()
  wo.spell = not wo.spell -- local to window
  utils.notify(string.format("spell %s", bool2str(wo.spell)), _vim.log.levels.INFO)
end

--- Toggle laststatus=3|2|0
function M.toggle_statusline()
  local laststatus = opt.laststatus:get()
  local status
  if laststatus == 0 then
    opt.laststatus = 2
    status = "local"
  elseif laststatus == 2 then
    opt.laststatus = 3
    status = "global"
  elseif laststatus == 3 then
    opt.laststatus = 0
    status = "off"
  end
  utils.notify(string.format("statusline %s", status), _vim.log.levels.INFO)
end

--- Toggle showtabline=2|0
function M.toggle_tabline()
  opt.showtabline = opt.showtabline:get() == 0 and 2 or 0
  utils.notify(string.format("tabline %s", bool2str(opt.showtabline:get() == 2)), _vim.log.levels.INFO)
end

--- Toggle notifications for UI toggles
function M.toggle_ui_notifications()
  g.notifications_enabled = not g.notifications_enabled
  utils.notify(string.format("Notifications %s", bool2str(g.notifications_enabled)), _vim.log.levels.INFO)
end

--- Toggle URL/URI syntax highlighting rules
function M.toggle_url_effect()
  g.url_effect_enabled = not g.url_effect_enabled
  require("base.utils").set_url_effect()
  utils.notify(string.format("URL effect %s", bool2str(g.url_effect_enabled)), _vim.log.levels.INFO)
end

--- Toggle wrap
function M.toggle_wrap()
  wo.wrap = not wo.wrap -- local to window
  utils.notify(string.format("wrap %s", bool2str(wo.wrap)), _vim.log.levels.INFO)
end

--- Toggle zen mode
--- @param bufnr? number the buffer to toggle `zen mode` on.
function M.toggle_zen_mode(bufnr)
  bufnr = bufnr or 0
  if not b[bufnr].zen_mode then
    b[bufnr].zen_mode = true
  else
    b[bufnr].zen_mode = false
  end
  utils.notify(string.format("zen mode %s", bool2str(b[bufnr].zen_mode)), _vim.log.levels.INFO)
  cmd "ZenMode"
end

return M
