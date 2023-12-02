-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use('wbthomason/packer.nvim') -- package manager
  -- use {'nvim-telescope/telescope.nvim', tag = '0.1.1', requires = { {'nvim-lua/plenary.nvim'} }} -- fuzzy finder
  use {'nvim-telescope/telescope.nvim', tag = '0.1.4', requires = { {'nvim-lua/plenary.nvim'} }} -- fuzzy finder
  -- use {'nvim-telescope/telescope.nvim', requires = { {'nvim-lua/plenary.nvim'} }} -- fuzzy finder
  use {'nvim-treesitter/nvim-treesitter', tag = 'v0.9.1', {run = ':TSUpdate'}} -- syntax highlighting
  use('theprimeagen/harpoon') -- tag files for quick access
  use('mbbill/undotree') -- detailed tree of file changes
  use('tpope/vim-commentary') -- allows commenting out/in with shortcuts
  use('tpope/vim-surround') -- allows manipulation of surroundin braces, quotes etc
  use('m4xshen/autoclose.nvim') -- adds closing parens, curlies, etc
  use('Mofiqul/vscode.nvim') -- color scheme of vim-code-dark
  use('simrat39/rust-tools.nvim')
  use {
    'prettier/vim-prettier',
    run = 'yarn install',
    ft = {'javascript', 'typescript', 'css', 'less', 'scss', 'graphql', 'markdown', 'vue', 'html', 'python'}
  }
  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    requires = {
      {'neovim/nvim-lspconfig'},             -- Required
      {                                      -- Optional
      'williamboman/mason.nvim',
      run = function()
        pcall(vim.cmd, 'MasonUpdate')
      end,
      },
      {'williamboman/mason-lspconfig.nvim'}, -- Optional
      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip',
      dependencies = {"rafamadriz/friendly-snippets"}},     -- Required
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'hrsh7th/cmp-vsnip'},
      {'hrsh7th/cmp-nvim-lua'},
      {'hrsh7th/cmp-nvim-lsp-signature-help'},
      {'saadparwaiz1/cmp_luasnip'},
      -- {'rafamadriz/friendly-snippets'},
      {'hrsh7th/cmp-nvim-lsp-signature-help'},
  }
}
end
)
