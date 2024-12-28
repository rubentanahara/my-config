return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    -- Enable nerd fonts
    vim.g.db_ui_use_nerd_fonts = 1

    -- Configure your database connections
    vim.g.dbs = {
      { name = "dev", url = "postgres://postgres:mypassword@localhost:5432/my-dev-db" },
      { name = "staging", url = "postgres://postgres:mypassword@localhost:5432/my-staging-db" },
      { name = "wp", url = "mysql://root@localhost/wp_awesome" },
      {
        name = "production",
        url = function()
          return vim.fn.system("get-prod-url")
        end,
      },
    }

    -- Optional: Add additional settings
    vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
    vim.g.db_ui_auto_execute_table_helpers = 1
  end,
}
