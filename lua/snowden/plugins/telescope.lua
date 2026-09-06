return {
  {
    "nvim-telescope/telescope.nvim",
    -- 0.1.8 calls vim.treesitter.language.ft_to_lang(), removed in Neovim 0.12.
    -- v0.2.1 is the newest tag by date and uses get_lang().
    tag = "v0.2.1",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
      vim.keymap.set("n", "<C-p>", builtin.git_files, {})
      vim.keymap.set("n", "<leader>ps", function()
        builtin.grep_string({ search = vim.fn.input("Grep > ") })
      end)
    end,
  },
}
