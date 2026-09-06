return {
  { "tpope/vim-commentary" },
  { "tpope/vim-surround" },
  { "tpope/vim-fugitive", keys = { { "<leader>gs", vim.cmd.Git, desc = "Git status" } } },

  {
    "m4xshen/autoclose.nvim",
    event = "InsertEnter",
    opts = { keys = { ["'"] = { close = false } } },
  },

  {
    "mbbill/undotree",
    keys = { { "<leader>u", vim.cmd.UndotreeToggle, desc = "Undo tree" } },
  },

  {
    "theprimeagen/harpoon",
    config = function()
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")

      vim.keymap.set("n", "<leader>a", mark.add_file)
      vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

      vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
      vim.keymap.set("n", "<C-t>", function() ui.nav_file(2) end)
      vim.keymap.set("n", "<C-n>", function() ui.nav_file(3) end)
      vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)
    end,
  },

  {
    "prettier/vim-prettier",
    build = "yarn install --frozen-lockfile --production",
    -- Loaded on demand by command, not by filetype: prettier decides what it can
    -- parse (see the BufWritePre guard in snowden/set.lua), so a filetype list here
    -- would only ever be a second, staler copy of that answer.
    cmd = { "Prettier", "PrettierAsync", "PrettierFragment", "PrettierPartial", "PrettierCli", "PrettierCliPath" },
  },
}
