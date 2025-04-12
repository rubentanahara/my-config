local M = {}

function M.setup()
  local opt = vim.opt
  local bo = vim.bo
  local cmd = vim.api.nvim_create_user_command
  local autocmd = vim.api.nvim_create_autocmd
  local keymap = vim.keymap
  local utils = require("base.utils")

  autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
    desc = "Nvim user events for file detection (BaseFile and BaseGitFile)",
    callback = function(args)
      local empty_buffer = vim.fn.resolve(vim.fn.expand "%") == ""
      local greeter = vim.api.nvim_get_option_value("filetype", { buf = args.buf }) == "alpha"
      local git_repo = vim.fn.executable("git") == 1 and utils.run_cmd(
        { "git", "-C", vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand "%"), ":p:h"), "rev-parse" }, false)

      -- For any file exept empty buffer, or the greeter (alpha)
      if not (empty_buffer or greeter) then
        utils.trigger_event("User BaseFile")

        -- Is the buffer part of a git repo?
        if git_repo then
          utils.trigger_event("User BaseGitFile")
        end
      end
    end,
  })
  autocmd({ "VimEnter" }, {
    desc = "Nvim user event that trigger a few ms after nvim starts",
    callback = function()
      -- If nvim is opened passing a filename, trigger the event inmediatelly.
      if #vim.fn.argv() >= 1 then
        -- In order to avoid visual glitches.
        utils.trigger_event("User BaseDefered", true)
        utils.trigger_event("BufEnter", true) -- also, initialize tabline_buffers.
      else                                    -- Wait some ms before triggering the event.
        vim.defer_fn(function()
          utils.trigger_event("User BaseDefered")
        end, 70)
      end
    end,
  })

  autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
    desc = "Save view with mkview for real files",
    callback = function(args)
      if vim.b[args.buf].view_activated then
        vim.cmd.mkview { mods = { emsg_silent = true } }
      end
    end,
  })
  autocmd("BufWinEnter", {
    desc = "Try to load file view if available and enable view saving for real files",
    callback = function(args)
      if not vim.b[args.buf].view_activated then
        local filetype =
            vim.api.nvim_get_option_value("filetype", { buf = args.buf })
        local buftype =
            vim.api.nvim_get_option_value("buftype", { buf = args.buf })
        local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
        if
            buftype == ""
            and filetype
            and filetype ~= ""
            and not vim.tbl_contains(ignore_filetypes, filetype)
        then
          vim.b[args.buf].view_activated = true
          vim.cmd.loadview { mods = { emsg_silent = true } }
        end
      end
    end,
  })

  autocmd("BufWritePre", {
    desc = "Automatically create parent directories if they don't exist when saving a file",
    callback = function(args)
      local buf_is_valid_and_listed = vim.api.nvim_buf_is_valid(args.buf)
          and vim.bo[args.buf].buflisted

      if buf_is_valid_and_listed then
        vim.fn.mkdir(vim.fn.fnamemodify(
          vim.uv.fs_realpath(args.match) or args.match, ":p:h"), "p")
      end
    end,
  })

  -- ## COOL HACKS ------------------------------------------------------------
  vim.api.nvim_set_hl(0, 'HighlightURL', { underline = true })
  autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
    desc = "URL Highlighting",
    callback = function() utils.set_url_effect() end,
  })

  autocmd("VimEnter", {
    desc = "Disable right contextual menu warning message",
    callback = function()
      -- Revome from menu
      vim.api.nvim_command [[aunmenu PopUp.How-to\ disable\ mouse]]
      vim.api.nvim_command [[aunmenu PopUp.Inspect]]
      vim.api.nvim_command [[aunmenu PopUp.-1-]] -- You can remove a separator like this.

      -- Add to menu
      vim.api.nvim_command [[menu PopUp.Format\ \Code <cmd>silent! Format<CR>]]
      vim.api.nvim_command [[menu PopUp.-1- <Nop>]]
      vim.api.nvim_command [[menu PopUp.Toggle\ \Breakpoint <cmd>:lua require('dap').toggle_breakpoint()<CR>]]
      vim.api.nvim_command [[menu PopUp.Debugger\ \Continue <cmd>:DapContinue<CR>]]
      vim.api.nvim_command [[menu PopUp.Run\ \Test <cmd>:Neotest run<CR>]]
    end,
  })

  autocmd("FileType", {
    desc = "Unlist quickfist buffers",
    pattern = "qf",
    callback = function() vim.opt_local.buflisted = false end,
  })

  autocmd("BufWritePre", {
    desc = "Close all notifications on BufWritePre",
    callback = function()
      require("notify").dismiss({ pending = true, silent = true })
    end,
  })

  -- Extra commands
  ----------------------------------------------

  -- Change working directory
  cmd("Cwd", function()
    vim.cmd(":cd %:p:h")
    vim.cmd(":pwd")
  end, { desc = "cd current file's directory" })

  -- Set working directory (alias)
  cmd("Swd", function()
    vim.cmd(":cd %:p:h")
    vim.cmd(":pwd")
  end, { desc = "cd current file's directory" })

  -- Write all buffers
  cmd("WriteAllBuffers", function()
    vim.cmd("wa")
  end, { desc = "Write all changed buffers" })

  -- Close all notifications
  cmd("CloseNotifications", function()
    require("notify").dismiss({ pending = true, silent = true })
  end, { desc = "Dismiss all notifications" })


  -- Disable the concealing in some file formats
  autocmd("FileType", {
    pattern = { "json", "jsonc", "markdown" },
    callback = function()
      opt.conceallevel = 0
    end
  })

  -- Resize splits if window got resized
  autocmd({ "VimResized" }, {
    callback = function()
      local current_tab = vim.fn.tabpagenr()
      cmd("tabdo wincmd =")
      cmd("tabnext " .. current_tab)
    end,
  })

  -- Close some filetypes with <q>
  autocmd("FileType", {
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
      bo[event.buf].buflisted = false
      keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
  })
end

return M
