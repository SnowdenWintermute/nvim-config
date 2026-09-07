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
    end,
  },
}
