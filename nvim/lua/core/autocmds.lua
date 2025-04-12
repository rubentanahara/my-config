local M = {}

function M.setup()
  local function augroup(name)
    return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
  end

  -- Disable the concealing in some file formats
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "json", "jsonc", "markdown" },
    callback = function()
      vim.opt.conceallevel = 0
    end
  })

  -- Resize splits if window got resized
  vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
      local current_tab = vim.fn.tabpagenr()
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end,
  })

  -- Close some filetypes with <q>
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
      "help",
      "lspinfo",
      "man",
      "notify",
      "qf",
      "spectre_panel",
      "startuptime",
      "checkhealth",
    },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
  })
end

return M

