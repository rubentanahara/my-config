local M = {}
local utils = require("base.utils")
local maps = require("base.utils").get_mappings_template()

function M.setup()
  -- standard Operations -----------------------------------------------------
  maps.n["j"] =
  { "v:count == 0 ? 'gj' : 'j'", expr = true, desc = "Move cursor down" }
  maps.n["k"] =
  { "v:count == 0 ? 'gk' : 'k'", expr = true, desc = "Move cursor up" }
  maps.n["<leader>w"] = { "<cmd>w<cr>", desc = "Save" }
  maps.n["<leader>W"] = { "<cmd>w<cr>", desc = "Save all" }
  maps.n["<leader>Q"] = { "<cmd>wa|q<cr>", desc = "Save All and Quit" }
  maps.n["<leader>q"] = { "<cmd>q<cr>", desc = "Quit" }
  maps.n["<leader>n"] = { "<cmd>enew<cr>", desc = "New file" }
  maps.n["gx"] =
  { utils.open_with_program, desc = "Open the file under cursor with a program" }
  maps.n["<C-s>"] = { "<cmd>w!<cr>", desc = "Force write" }
  maps.n["0"] =
  { "^", desc = "Go to the fist character of the line (aliases 0 to ^)" }


  -- Exit insert mode
  maps.i["jk"] = {
    "<ESC>", 
    noremap = true, 
    silent = true,
    desc = "Exit insert mode"
  }

  -- Navigate within insert mode
  maps.i["<C-b>"] = {
    "<ESC>^i",
    noremap = true,
    silent = true,
    desc = "Go to beginning of line"
  }

  maps.i["<C-e>"] = {
    "<ESC>$a",
    noremap = true,
    silent = true,
    desc = "Go to end of line"
  }

  -- Move Lines
  maps.n["<A-j>"] = {
    "<cmd>execute 'move .+' . v:count1<cr>==",
    noremap = true,
    silent = true,
    desc = "Move Down"
  }

  maps.n["<A-k>"] = {
    "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==",
    noremap = true,
    silent = true,
    desc = "Move Up"
  }

  maps.i["<A-j>"] = {
    "<esc><cmd>m .+1<cr>==gi",
    noremap = true,
    silent = true,
    desc = "Move Down"
  }

  maps.i["<A-k>"] = {
    "<esc><cmd>m .-2<cr>==gi",
    noremap = true,
    silent = true,
    desc = "Move Up"
  }

  maps.v["<A-j>"] = {
    ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",
    noremap = true,
    silent = true,
    desc = "Move Down"
  }

  maps.v["<A-k>"] = {
    ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv",
    noremap = true,
    silent = true,
    desc = "Move Up"
  }


  -- Better indenting
  maps.v["<"] = {
    "<gv",
    noremap = true,
    silent = true,
    desc = "Indent left"
  }
  maps.v[">"] = {
    ">gv",
    noremap = true,
    silent = true,
    desc = "Indent right"
  }

  -- Diagnostic keymaps
  maps.n["[d"] = {
    vim.diagnostic.goto_prev,
    noremap = true,
    silent = true,
    desc = "Previous diagnostic"
  }
  maps.n["]d"] = {
    vim.diagnostic.goto_next,
    noremap = true,
    silent = true,
    desc = "Next diagnostic"
  }
  maps.n["gl"] = {
    vim.diagnostic.open_float,
    noremap = true,
    silent = true,
    desc = "Show diagnostic"
  }

  -- Windows
  maps.n["ss"] = {
    ":split<CR>",
    noremap = true,
    silent = true,
    desc = "Horizontal Window Split"
  }
  maps.n["sv"] = {
    ":vsplit<CR>",
    noremap = true,
    silent = true,
    desc = "Vertical Window Split"
  }

  -- Window resizing
  maps.n["<C-w><up>"] = {
    ":resize +3<CR>",
    noremap = true,
    silent = true,
    desc = "Resize Horizontal Up"
  }
  maps.n["<C-w><down>"] = {
    ":resize -3<CR>",
    noremap = true,
    silent = true,
    desc = "Resize Horizontal Down"
  }
  maps.n["<C-w><left>"] = {
    ":vertical resize +3<CR>",
    noremap = true,
    silent = true,
    desc = "Resize Vertical Left"
  }
  maps.n["<C-w><right>"] = {
    ":vertical resize -3<CR>",
    noremap = true,
    silent = true,
    desc = "Resize Vertical Right"
  }

  -- Resize window using <ctrl> arrow keys
  maps.n["<C-Up>"] = {
    "<cmd>resize +3<cr>",
    noremap = true,
    silent = true,
    desc = "Increase Window Height"
  }
  maps.n["<C-Down>"] = {
    "<cmd>resize -3<cr>",
    noremap = true,
    silent = true,
    desc = "Decrease Window Height"
  }
  maps.n["<C-Left>"] = {
    "<cmd>vertical resize -3<cr>",
    noremap = true,
    silent = true,
    desc = "Decrease Window Width"
  }
  maps.n["<C-Right>"] = {
    "<cmd>vertical resize +3<cr>",
    noremap = true,
    silent = true,
    desc = "Increase Window Width"
  }

  -- Useful keymaps
  maps.n["+"] = {
    "<C-a>",
    noremap = true,
    silent = true,
    desc = "Increment"
  }
  maps.n["-"] = {
    "<C-x>",
    noremap = true,
    silent = true,
    desc = "Decrement"
  }

  -- Commenting
  maps.n["gcb"] = {
    "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>",
    noremap = true,
    silent = true,
    desc = "Add Comment Below"
  }
  maps.n["gca"] = {
    "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>",
    noremap = true,
    silent = true,
    desc = "Add Comment Above"
  }

  -- clipboard ---------------------------------------------------------------
  -- Make 'c' key not copy to clipboard when changing a character.
  maps.n["c"] = { '"_c', desc = "Change without yanking" }
  maps.n["C"] = { '"_C', desc = "Change without yanking" }
  maps.x["c"] = { '"_c', desc = "Change without yanking" }
  maps.x["C"] = { '"_C', desc = "Change without yanking" }

  -- Make 'x' key not copy to clipboard when deleting a character.
  maps.n["x"] = {
    -- Also let's allow 'x' key to delete blank lines in normal mode.
    function()
      if vim.fn.col "." == 1 then
        local line = vim.fn.getline "."
        if line:match "^%s*$" then
          vim.api.nvim_feedkeys('"_dd', "n", false)
          vim.api.nvim_feedkeys("$", "n", false)
        else
          vim.api.nvim_feedkeys('"_x', "n", false)
        end
      else
        vim.api.nvim_feedkeys('"_x', "n", false)
      end
    end,
    noremap = true,
    silent = true,
    desc = "Delete character without yanking it",
  }
  maps.x["x"] = { '"_x', desc = "Delete all characters in line" }

  -- Same for shifted X
  maps.n["X"] = {
    -- Also let's allow 'x' key to delete blank lines in normal mode.
    function()
      if vim.fn.col "." == 1 then
        local line = vim.fn.getline "."
        if line:match "^%s*$" then
          vim.api.nvim_feedkeys('"_dd', "n", false)
          vim.api.nvim_feedkeys("$", "n", false)
        else
          vim.api.nvim_feedkeys('"_X', "n", false)
        end
      else
        vim.api.nvim_feedkeys('"_X', "n", false)
      end
    end,
    desc = "Delete before character without yanking it",
  }
  maps.x["X"] = { '"_X', desc = "Delete all characters in line" }

  -- Override nvim default behavior so it doesn't auto-yank when pasting on visual mode.
  maps.x["p"] = { "P", desc = "Paste content you've previourly yanked" }
  maps.x["P"] = { "p", desc = "Yank what you are going to override, then paste" }

  -- search highlighting ------------------------------------------------------
  maps.n["<leader><ENTER>"] = {
    function()
      if vim.fn.hlexists("Search") then
        vim.cmd("nohlsearch")
      else
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<ESC>", true, true, true),
          "n",
          true
        )
      end
    end,
  }

  -- Improved tabulation ------------------------------------------------------
  maps.x["<S-Tab>"] = { "<gv", desc = "unindent line" }
  maps.x["<Tab>"] = { ">gv", desc = "indent line" }
  maps.x["<"] = { "<gv", desc = "unindent line" }
  maps.x[">"] = { ">gv", desc = "indent line" }

  -- improved gg --------------------------------------------------------------
  maps.n["gg"] = {
    function()
      vim.g.minianimate_disable = true
      if vim.v.count > 0 then
        vim.cmd("normal! " .. vim.v.count .. "gg")
      else
        vim.cmd("normal! gg0")
      end
      vim.g.minianimate_disable = false
    end,
    desc = "gg and go to the first position",
  }
  maps.n["G"] = {
    function()
      vim.g.minianimate_disable = true
      vim.cmd("normal! G$")
      vim.g.minianimate_disable = false
    end,
    desc = "G and go to the last position",
  }
  maps.x["gg"] = {
    function()
      vim.g.minianimate_disable = true
      if vim.v.count > 0 then
        vim.cmd("normal! " .. vim.v.count .. "gg")
      else
        vim.cmd("normal! gg0")
      end
      vim.g.minianimate_disable = false
    end,
    desc = "gg and go to the first position (visual)",
  }
  maps.x["G"] = {
    function()
      vim.g.minianimate_disable = true
      vim.cmd("normal! G$")
      vim.g.minianimate_disable = false
    end,
    desc = "G and go to the last position (visual)",
  }

  -- Lazy
  maps.n["<leader>l"] =  {
    ":Lazy<CR>",
    noremap = true,
    silent = true,
    desc = "Open Lazy (Lazy.nvim)",
  }


  utils.set_mappings(maps)
end
return M
