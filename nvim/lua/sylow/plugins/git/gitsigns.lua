local utils = require('sylow.utils')

return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  lazy= false,
  cond = function()
    return utils.is_git_repo()
  end,
  config = function()
    require('gitsigns').setup()

    vim.g.fugitive_no_maps = 1

    local gitsigns = require('gitsigns')
    local keymap = vim.keymap.set

    keymap('n', ']g', function()
      gitsigns.nav_hunk('next')
    end, { desc = 'Next Git hunk' })
    keymap('n', '[g', function()
      gitsigns.nav_hunk('prev')
    end, { desc = 'Previous Git hunk' })
    keymap('n', '<leader>gl', gitsigns.blame_line, { desc = 'View Git blame' })
    keymap('n', '<leader>gL', function()
      gitsigns.blame_line({ full = true })
    end, { desc = 'View full Git blame' })
    keymap('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'Preview Git hunk' })
    keymap('n', '<leader>gh', gitsigns.reset_hunk, { desc = 'Reset Git hunk' })
    keymap('n', '<leader>gr', gitsigns.reset_buffer, { desc = 'Reset Git buffer' })
    keymap('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'Stage Git hunk' })
    keymap('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'Stage Git buffer' })
    keymap('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = 'Unstage Git hunk' })
    keymap('n', '<leader>gd', gitsigns.diffthis, { desc = 'View Git diff' })
    keymap('n', '<leader>gP', '<cmd>GBrowse<cr>', { desc = 'Open in GitHub' })
  end,
}
