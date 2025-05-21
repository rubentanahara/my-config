local M = {}

local utils = require('sylow.core.utils')

local function bool2str(bool)
  return bool and 'on' or 'off'
end

------------------------------------------
-- UI Display Utilities
------------------------------------------

function M.change_number()
  local number = vim.wo.number -- local to window
  local relativenumber = vim.wo.relativenumber -- local to window
  if not number and not relativenumber then
    vim.wo.number = true
  elseif number and not relativenumber then
    vim.wo.relativenumber = true
  elseif number and relativenumber then
    vim.wo.number = false
  else -- not number and relativenumber
    vim.wo.relativenumber = false
  end
  utils.notify(string.format('number %s, relativenumber %s', bool2str(vim.wo.number), bool2str(vim.wo.relativenumber)))
end

function M.set_indent()
  local input_avail, input = pcall(vim.fn.input, 'Set indent value (>0 expandtab, <=0 noexpandtab): ')

  if input_avail then
    local indent = tonumber(input)
    if not indent or indent == 0 then
      return
    end

    -- Set expandtab based on sign
    vim.bo.expandtab = (indent > 0)

    -- Use absolute value for indent settings
    indent = math.abs(indent)
    vim.bo.tabstop = indent
    vim.bo.softtabstop = indent
    vim.bo.shiftwidth = indent

    -- Notify the user of changes
    utils.notify(string.format('indent=%d %s', indent, vim.bo.expandtab and 'expandtab' or 'noexpandtab'))
  end
end

------------------------------------------
-- UI Feature Toggles
------------------------------------------

function M.toggle_animations()
  -- Toggle global setting
  vim.g.minianimate_disable = not vim.g.minianimate_disable

  -- Notify user of current state
  local state = vim.g.minianimate_disable
  utils.notify(string.format('animations %s', bool2str(not state)))
end

function M.toggle_autoformat()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  utils.notify(string.format('Global autoformatting %s', bool2str(vim.g.autoformat_enabled)))
end

function M.toggle_background()
  vim.go.background = vim.go.background == 'light' and 'dark' or 'light'
  utils.notify(string.format('background=%s', vim.go.background))
end

function M.toggle_buffer_autoformat(bufnr)
  bufnr = bufnr or 0
  local old_val = vim.b[bufnr].autoformat_enabled
  if old_val == nil then
    old_val = vim.g.autoformat_enabled
  end
  vim.b[bufnr].autoformat_enabled = not old_val
  utils.notify(string.format('Buffer autoformatting %s', bool2str(vim.b[bufnr].autoformat_enabled)))
end

function M.toggle_buffer_inlay_hints(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].inlay_hints_enabled = not vim.b[bufnr].inlay_hints_enabled
  vim.lsp.inlay_hint.enable(vim.b[bufnr].inlay_hints_enabled, { bufnr = bufnr })
  utils.notify(string.format('Buffer inlay hints %s', bool2str(vim.b[bufnr].inlay_hints_enabled)))
end

function M.toggle_buffer_semantic_tokens(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].semantic_tokens_enabled = not vim.b[bufnr].semantic_tokens_enabled
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens[vim.b[bufnr].semantic_tokens_enabled and 'start' or 'stop'](bufnr, client.id)
      utils.notify(string.format('Buffer lsp semantic highlighting %s', bool2str(vim.b[bufnr].semantic_tokens_enabled)))
    end
  end
end

function M.toggle_buffer_syntax(bufnr)
  -- HACK: this should just be `bufnr = bufnr or 0` but it looks like
  --       `vim.treesitter.stop` has a bug with `0` being current.
  bufnr = (bufnr and bufnr ~= 0) and bufnr or vim.api.nvim_win_get_buf(0)
  local ts_avail, parsers = pcall(require, 'nvim-treesitter.parsers')
  if vim.bo[bufnr].syntax == 'off' then
    if ts_avail and parsers.has_parser() then
      vim.treesitter.start(bufnr)
    end
    vim.bo[bufnr].syntax = 'on'
    if not vim.b.semantic_tokens_enabled then
      M.toggle_buffer_semantic_tokens(bufnr, true)
    end
  else
    if ts_avail and parsers.has_parser() then
      vim.treesitter.stop(bufnr)
    end
    vim.bo[bufnr].syntax = 'off'
    if vim.b.semantic_tokens_enabled then
      M.toggle_buffer_semantic_tokens(bufnr, true)
    end
  end
  utils.notify(string.format('syntax %s', bool2str(vim.bo[bufnr].syntax)))
end

function M.toggle_codelens(bufnr)
  bufnr = bufnr or 0
  vim.g.codelens_enabled = not vim.g.codelens_enabled
  if vim.g.codelens_enabled then
    vim.lsp.codelens.refresh({ bufnr = bufnr })
  else
    vim.lsp.codelens.clear()
  end
  utils.notify(string.format('CodeLens %s', bool2str(vim.g.codelens_enabled)))
end

function M.toggle_coverage_signs(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].coverage_signs_enabled = not vim.b[bufnr].coverage_signs_enabled
  if vim.b[bufnr].coverage_signs_enabled then
    utils.notify(
      'Coverage signs on:'
        .. '\n\n- Git signs will be temporary disabled.'
        .. "\n- Diagnostic signs won't be automatically disabled."
    )
    vim.cmd('Gitsigns toggle_signs')
    require('coverage').load(true)
  else
    utils.notify('Coverage signs off:\n\n- Git signs re-enabled.')
    require('coverage').hide()
    vim.cmd('Gitsigns toggle_signs')
  end
end

function M.toggle_cmp()
  vim.g.cmp_enabled = not vim.g.cmp_enabled
  local ok, _ = pcall(require, 'cmp')
  utils.notify(ok and string.format('completion %s', bool2str(vim.g.cmp_enabled)) or 'completion not available')
end

function M.toggle_conceal()
  vim.opt.conceallevel = vim.opt.conceallevel:get() == 0 and 2 or 0
  utils.notify(string.format('conceal %s', bool2str(vim.opt.conceallevel:get() == 2)))
end

function M.toggle_diagnostics()
  vim.g.diagnostics_mode = (vim.g.diagnostics_mode - 1) % 4
  vim.diagnostic.config(require('sylow.core.utils.lsp').diagnostics[vim.g.diagnostics_mode])
  if vim.g.diagnostics_mode == 0 then
    utils.notify 'diagnostics off'
  elseif vim.g.diagnostics_mode == 1 then
    utils.notify 'only status diagnostics'
  elseif vim.g.diagnostics_mode == 2 then
    utils.notify 'virtual text off'
  else
    utils.notify 'all diagnostics on'
  end
end

local last_active_foldcolumn
function M.toggle_foldcolumn()
  local curr_foldcolumn = vim.wo.foldcolumn
  if curr_foldcolumn ~= '0' then
    last_active_foldcolumn = curr_foldcolumn
  end
  vim.wo.foldcolumn = curr_foldcolumn == '0' and (last_active_foldcolumn or '1') or '0'
  utils.notify(string.format('foldcolumn=%s', vim.wo.foldcolumn))
end

function M.toggle_inlay_hints(bufnr)
  bufnr = bufnr or 0
  vim.g.inlay_hints_enabled = not vim.g.inlay_hints_enabled -- flip global state
  vim.b.inlay_hints_enabled = not vim.g.inlay_hints_enabled -- sync buffer state
  vim.lsp.buf.inlay_hint.enable(vim.g.inlay_hints_enabled, { bufnr = bufnr }) -- apply state
  utils.notify(string.format('Global inlay hints %s', bool2str(vim.g.inlay_hints_enabled)))
end

function M.toggle_lsp_signature()
  local state = require('lsp_signature').toggle_float_win()
  utils.notify(string.format('lsp signature %s', bool2str(state)))
end

function M.toggle_paste()
  vim.opt.paste = not vim.opt.paste:get() -- local to window
  utils.notify(string.format('paste %s', bool2str(vim.opt.paste:get())))
end

function M.toggle_signcolumn()
  if vim.wo.signcolumn == 'no' then
    vim.wo.signcolumn = 'yes'
  elseif vim.wo.signcolumn == 'yes' then
    vim.wo.signcolumn = 'auto'
  else
    vim.wo.signcolumn = 'no'
  end
  utils.notify(string.format('signcolumn=%s', vim.wo.signcolumn))
end

function M.toggle_spell()
  vim.wo.spell = not vim.wo.spell -- local to window
  utils.notify(string.format('spell %s', bool2str(vim.wo.spell)))
end

function M.toggle_statusline()
  local laststatus = vim.opt.laststatus:get()
  local status
  if laststatus == 0 then
    vim.opt.laststatus = 2
    status = 'local'
  elseif laststatus == 2 then
    vim.opt.laststatus = 3
    status = 'global'
  elseif laststatus == 3 then
    vim.opt.laststatus = 0
    status = 'off'
  end
  utils.notify(string.format('statusline %s', status))
end

function M.toggle_tabline()
  vim.opt.showtabline = vim.opt.showtabline:get() == 0 and 2 or 0
  utils.notify(string.format('tabline %s', bool2str(vim.opt.showtabline:get() == 2)))
end

function M.toggle_ui_notifications()
  vim.g.notifications_enabled = not vim.g.notifications_enabled
  utils.notify(string.format('Notifications %s', bool2str(vim.g.notifications_enabled)))
end

function M.toggle_url_effect()
  vim.g.url_effect_enabled = not vim.g.url_effect_enabled
  require('sylow.core.utils').set_url_effect()
  utils.notify(string.format('URL effect %s', bool2str(vim.g.url_effect_enabled)))
end

function M.toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap -- local to window
  utils.notify(string.format('wrap %s', bool2str(vim.wo.wrap)))
end

function M.toggle_zen_mode(bufnr)
  bufnr = bufnr or 0
  if not vim.b[bufnr].zen_mode then
    vim.b[bufnr].zen_mode = true
  else
    vim.b[bufnr].zen_mode = false
  end
  utils.notify(string.format('zen mode %s', bool2str(vim.b[bufnr].zen_mode)))
  vim.cmd 'ZenMode'
end

function M.clear_search()
  if vim.fn.hlexists('Search') then
    vim.cmd('nohlsearch')
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, true, true), 'n', true)
  end
end

return M
