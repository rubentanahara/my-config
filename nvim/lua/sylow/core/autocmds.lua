local utils = require('sylow.utils')
local lsp_utils = require('sylow.utils.lsp')
local fn = vim.fn
local opt_local = vim.opt_local
local bo = vim.bo
local cmd = vim.cmd

local options = {
  text_filetypes = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  view_ignore_filetypes = { 'gitcommit', 'gitrebase', 'svg', 'hgcommit' },
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
  unlist_filetypes = { 'man', 'help' },
  indentscope_ignored_filetypes = {
    'aerial',
    'dashboard',
    'help',
    'lazy',
    'leetcode.nvim',
    'mason',
    'neo-tree',
    'NvimTree',
    'neogitstatus',
    'notify',
    'startify',
    'toggleterm',
    'Trouble',
    'calltree',
    'coverage',
  },
}

utils.create_autocmd('LspAttach', {
  desc = 'Apply default LSP mappings when an LSP server attaches to a buffer',
  callback = function(e)
    local client = vim.lsp.get_client_by_id(e.data.client_id)
    -- print(client.name)
    if client ~= nil then
      lsp_utils.apply_user_lsp_mappings(client, e.buf)
    end
  end,
})

utils.create_autocmd({ 'FileType' }, {
  desc = 'Disable indentscope for certain filetypes',
  callback = function()
    if vim.tbl_contains(options.indentscope_ignored_filetypes, bo.filetype) then
      vim.b.miniindentscope_disable = true
    end
  end,
})

utils.create_autocmd('FileType', {
  desc = 'Make certain filetypes closable with q and unlist them',
  pattern = options.close_with_q_filetypes,
  callback = function(event)
    bo[event.buf].buflisted = false -- Corrected this line
    vim.keymap.set('n', 'q', function()
      vim.cmd('close')
      pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
    end, {
      buffer = event.buf,
      silent = true,
      desc = 'Quit buffer',
    })
  end,
})

utils.create_autocmd('CmdlineEnter', {
  desc = 'Hide cmd line',
  pattern = { '/', '?' },
  callback = function()
    vim.opt.cmdheight = 0
  end,
})

utils.create_autocmd('CmdlineLeave', {
  desc = 'Use hlslens after find',
  pattern = { '/', '?' },
  callback = function()
    vim.opt.cmdheight = 0
    vim.defer_fn(utils.start_hlslens, 10)
  end,
})

utils.create_autocmd('FileType', {
  desc = 'Hide neo-tree buffers from the buffer list',
  pattern = 'neo-tree',
  callback = function(opts)
    vim.schedule(function()
      vim.api.nvim_buf_set_option(opts.buf, 'buflisted', false)
    end)
  end,
})

utils.create_autocmd('FileType', {
  desc = 'Fix conceallevel for JSON files',
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function()
    opt_local.conceallevel = 0
  end,
})

utils.create_autocmd('FileType', {
  desc = 'Enable wrapping and spell checking in text filetypes',
  pattern = options.text_filetypes,
  callback = function()
    opt_local.wrap = true
    opt_local.spell = true
  end,
})

utils.create_autocmd('VimResized', {
  desc = 'Handles window resizing events and ensures the dashboard gets properly refreshed',
  pattern = '*',
  callback = function()
    if bo.filetype == 'dashboard' then
      cmd('doautocmd FileType dashboard')
    end
  end,
})

utils.create_autocmd('TextYankPost', {
  desc = 'Highlight text on yank',
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

utils.create_autocmd('VimResized', {
  desc = 'Equalize window sizes when terminal is resized',
  callback = function()
    local current_tab = fn.tabpagenr()
    cmd('tabdo wincmd =')
    cmd('tabnext ' .. current_tab)
  end,
})
