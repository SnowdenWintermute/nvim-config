-- rust-tools.nvim is archived; rustaceanvim is its maintained successor.
-- It configures and owns rust_analyzer itself, so it must not also be
-- enabled through mason-lspconfig.
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false,
    init = function()
      vim.g.rustaceanvim = {
        tools = {
          float_win_config = { border = "rounded" },
        },
        server = {
          on_attach = function(_, bufnr)
            vim.keymap.set("n", "<C-space>", function()
              vim.cmd.RustLsp({ "hover", "actions" })
            end, { buffer = bufnr, desc = "Rust hover actions" })
          end,
          default_settings = {
            ["rust-analyzer"] = {
              checkOnSave = true,
              check = { command = "clippy" },
              inlayHints = {
                parameterHints = { enable = false },
              },
            },
          },
        },
      }
    end,
  },
}
