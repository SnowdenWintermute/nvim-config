-- C# / Razor / Blazor.
--
-- Uses the Roslyn language server (the same one VS Code's C# extension runs)
-- rather than OmniSharp. Razor and Blazor work through Roslyn's co-hosting
-- support, which replaces the old rzls.nvim setup.
--
-- Requires:
--   * Neovim >= 0.12
--   * :MasonInstall roslyn        (>= 5.8.0-1.26262.10, from the Crashdummyy registry)
--   * :MasonInstall html-lsp      (Razor delegates its HTML regions to it)
--
-- :checkhealth roslyn verifies all of the above.
return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    opts = {
      filewatching = "auto",
      -- Look beyond the cwd for a .sln, so opening a file deep in a repo
      -- still finds the solution above it.
      broad_search = true,
    },
    config = function(_, opts)
      require("roslyn").setup(opts)

      -- roslyn.nvim backs each .razor file with a virtual html buffer, and fills
      -- it via nvim_buf_set_lines. That loads the buffer, which normally fires
      -- BufNewFile and detects the filetype -- but autocommands do not nest, so
      -- when the buffer is first created from inside our BufWritePre format hook
      -- the filetype stays empty and the html client never attaches to it. Every
      -- html request roslyn forwards after that spends the document manager's
      -- full 5s client wait and then returns no edits, so the save hangs and the
      -- file comes out unformatted, for the rest of the session.
      local document_manager = require("roslyn.razor.documentManager")
      local update_document_text = document_manager.updateDocumentText
      document_manager.updateDocumentText = function(self, uri, checksum, content)
        local document = update_document_text(self, uri, checksum, content)
        if vim.bo[document.buf].filetype ~= "html" then
          vim.bo[document.buf].filetype = "html"
        end
        return document
      end

      -- Razor cohosting sometimes answers textDocument/diagnostic with an item
      -- whose range failed to map from the generated C#/HTML document back to
      -- the .razor file. The JSON null arrives as vim.NIL, and the stock
      -- handler indexes diagnostic.range unconditionally
      -- (runtime/lua/vim/lsp/diagnostic.lua:99), so one bad item throws and
      -- every diagnostic in that response is dropped. Filter them out first.
      local methods = vim.lsp.protocol.Methods
      local pull_diagnostics = vim.lsp.handlers[methods.textDocument_diagnostic]
      local function keep_mapped(items)
        return vim.tbl_filter(function(item)
          return type(item) == "table" and type(item.range) == "table"
        end, items or {})
      end
      vim.lsp.handlers[methods.textDocument_diagnostic] = function(err, result, ctx, config)
        if type(result) == "table" then
          if result.items then
            result.items = keep_mapped(result.items)
          end
          for _, related in pairs(result.relatedDocuments or {}) do
            if related.items then
              related.items = keep_mapped(related.items)
            end
          end
        end
        return pull_diagnostics(err, result, ctx, config)
      end
    end,
  },
}
