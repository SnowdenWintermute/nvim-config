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
  },
}
