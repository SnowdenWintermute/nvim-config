-- The `main` branch. `master` is frozen at Neovim 0.11 and crashes on 0.12
-- (nvim-treesitter#8636), so it is not an option here.
--
-- Requires the tree-sitter CLI >= 0.26.1. Every prebuilt CLI binary from
-- 0.26 on needs glibc 2.39 and Debian 12 has 2.36, so it is built from
-- source instead: `cargo install tree-sitter-cli --locked`.
--
-- Unlike `master`, this branch does not enable highlighting for you.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})

      local parsers = {
        "c", "c_sharp", "css", "html", "javascript", "json", "lua", "markdown",
        "markdown_inline", "query", "razor", "rust", "toml", "tsx", "typescript",
        "vim", "vimdoc", "yaml",
      }

      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("snowden_treesitter", { clear = true }),
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
