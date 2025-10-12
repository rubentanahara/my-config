local function setup_trouble()
  return {
    modes = {
      lsp = {
        win = { position = 'right' },
      },
    },
  }
end

local function toggle_trouble()
  require('trouble').toggle()
end

local function navigate_previous()
  local trouble = require('trouble')
  if trouble.is_open() then
    trouble.prev({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end

local function navigate_next()
  local trouble = require('trouble')
  if trouble.is_open() then
    trouble.next({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cnext)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end

local keys = {
  {
    '<leader>xx',
    toggle_trouble,
    desc = 'Diagnostics (Trouble)',
  },
  {
    '<leader>xX',
    '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
    desc = 'Buffer Diagnostics (Trouble)',
  },
  {
    '<leader>cs',
    '<cmd>Trouble symbols toggle<cr>',
    desc = 'Symbols (Trouble)',
  },
  {
    '<leader>cS',
    '<cmd>Trouble lsp toggle<cr>',
    desc = 'LSP references/definitions/... (Trouble)',
  },
  {
    '<leader>xL',
    '<cmd>Trouble loclist toggle<cr>',
    desc = 'Location List (Trouble)',
  },
  {
    '<leader>xQ',
    '<cmd>Trouble qflist toggle<cr>',
    desc = 'Quickfix List (Trouble)',
  },
  {
    '[d',
    navigate_previous,
    desc = 'Previous Trouble/Quickfix Item',
  },
  {
    ']d',
    navigate_next,
    desc = 'Next Trouble/Quickfix Item',
  },
}

return {
  {
    'folke/trouble.nvim',
    cmd = { 'Trouble', 'TroubleToggle', 'TroubleClose', 'TroubleRefresh' },
    event = 'VeryLazy',
    keys = keys,
    opts = setup_trouble,
  },
}
