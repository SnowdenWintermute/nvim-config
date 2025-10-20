local lsp = require("lsp-zero")
lsp.preset("recommended")
lsp.ensure_installed ({
	"ts_ls",
	"eslint",
  "cssls",
  "tailwindcss",
  "omnisharp",
})

local cmp = require('cmp')
require("luasnip.loaders.from_vscode").lazy_load { paths = { "./snippets/typescript" } }

-- C#
-- need to install omnisharp with MasonInstall first
require'lspconfig'.omnisharp.setup{
    cmd = { "/home/mike/.local/share/nvim/mason/packages/omnisharp/omnisharp" },
    enable_import_completion = true,
    enable_roslyn_analyzers = true,
    analyze_open_documents_only = true,
    enable_razor_support = true,
    root_dir = require'lspconfig'.util.root_pattern("*.sln", "*.csproj", ".git"),
    filetypes = {"cs", "html"},  
}

--- end C#

local luasnip = require("luasnip")
local cmp_select = {behavior = cmp.SelectBehavior.Select}
cmp.setup {
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  -- sources = {
  --   { name = 'nvim_lsp' },
  --   { name = 'luasnip' },
  --   { name = 'nvim_lsp_signature_help'},
  --   { name = 'path' },                              -- file paths
  --   { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
  --   { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
  --   { name = 'buffer', keyword_length = 2 },        -- source current buffer
  --   { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip 
  --   { name = 'calc'},                               -- source for math calculation
  -- },
}

local cmp_mappings = lsp.defaults.cmp_mappings({
	['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
	['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
	['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
	["<C-Space>"] = cmp.mapping.complete(),
})

lsp.set_preferences({
	sign_icons = { }
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})

require 'lspconfig'.tailwindcss.setup {
  -- capabilities = Capabilities,
 -- There add every filetype you want tailwind to work on
  filetypes = {
    "css",
    "scss",
    "sass",
    "html",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "rust",
  },
  init_options = {
    -- There you can set languages to be considered as different ones by tailwind lsp I guess same as includeLanguages in VSCod
    userLanguages = {
      rust = "html",
    },
  },
  -- Here If any of files from list will exist tailwind lsp will activate.
  root_dir = require 'lspconfig'.util.root_pattern('tailwind.config.js', 'tailwind.config.ts', 'postcss.config.js',
    'postcss.config.ts', 'windi.config.ts'),
}
