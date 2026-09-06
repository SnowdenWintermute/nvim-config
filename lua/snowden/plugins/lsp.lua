return {
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        -- Ships the Roslyn language server + nightly builds. Razor/Blazor
        -- support needs roslyn >= 5.8.0-1.26262.10, which the core registry
        -- does not carry.
        "github:Crashdummyy/mason-registry",
      },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "ts_ls", "eslint", "cssls", "html", "tailwindcss" },
      -- rust_analyzer is owned by rustaceanvim, roslyn by roslyn.nvim.
      automatic_enable = { exclude = { "rust_analyzer", "roslyn_ls", "omnisharp" } },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
      end

      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("tailwindcss", {
        filetypes = {
          "css", "scss", "sass", "html", "javascript", "javascriptreact",
          "typescript", "typescriptreact", "rust",
        },
        init_options = {
          userLanguages = { rust = "html" },
        },
        root_markers = {
          "tailwind.config.js", "tailwind.config.ts",
          "postcss.config.js", "postcss.config.ts", "windi.config.ts",
        },
      })

      -- Godot must be running with its LSP enabled.
      vim.lsp.config("gdscript", {
        cmd = { "nc", "localhost", "6005" },
      })

      vim.lsp.enable({ "ts_ls", "eslint", "cssls", "html", "tailwindcss", "gdscript" })

      vim.lsp.document_color.enable(true, nil, { style = "virtual" })

      vim.diagnostic.config({
        virtual_text = true,
        underline = true,
        update_in_insert = true,
        severity_sort = false,
        signs = false,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("snowden_lsp_attach", { clear = true }),
        callback = function(event)
          local opts = { buffer = event.buf, remap = false }

          -- Skip constructor definitions and land on the declaration instead.
          vim.keymap.set("n", "gd", function()
            vim.lsp.buf.definition({
              on_list = function(list)
                local items = vim.tbl_filter(function(item)
                  return not (item.text or ""):match("constructor")
                end, list.items)

                if #items == 0 then
                  items = list.items
                end

                -- Ambient declarations sort ahead of the real file (node_modules < packages).
                local sources = vim.tbl_filter(function(item)
                  return not (item.filename or ""):match("%.d%.ts$")
                end, items)

                if #sources > 0 then
                  items = sources
                end

                vim.fn.setqflist({}, " ", { title = list.title, items = items })
                vim.cmd.cfirst()
              end,
            })
          end, opts)

          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
          vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
          vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
          vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
          vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
        end,
      })
    end,
  },
}
