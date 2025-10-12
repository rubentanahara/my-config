local function search_replace()
  local grug = require('grug-far')
  local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')

  grug.open({
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
    },
  })
end

local keys = {
  {
    '<leader>sr',
    search_replace,
    mode = { 'n', 'v' },
    desc = 'Search and Replace (Grug Far)',
  },
}

local function setup_grug_far()
  return {
    headerMaxWidth = 80,
    window = {
      width = 0.9,
      height = 0.9,
    },
    results = {
      maxEntries = 1000,
    },
  }
end

return {
  {
    'MagicDuck/grug-far.nvim',
    cmd = {
      'GrugFar',
      'GrugFarLast',
      'GrugFarQuickfix',
      'GrugFarLoadLast',
    },
    keys = keys,
    opts = setup_grug_far,
  },
}
