vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

-- Floating windows (hover, signature help, diagnostics) get a border. The
-- built-in padding comes from the border, so without this they render flush
-- against the edge with the signature and docs mashed together.
vim.o.winborder = "rounded"

-- menuone: popup even when there's only one match
-- noinsert: do not insert text until a selection is made
-- noselect: do not auto-select, nvim-cmp handles this for us
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.shortmess:append("c")

vim.g.mapleader = " "
vim.o.mouse = "a"

vim.g["prettier#quickfix_enabled"] = 0

-- Absolute path is required: vim-prettier runs it through fnamemodify(..., ":p"),
-- so a bare "prettier" would resolve against the cwd. Setting this also short-circuits
-- the plugin's ancestor search, which errors (E1174) when it finds no node_modules prettier.
vim.g["prettier#exec_cmd_path"] = vim.fn.expand("~/.local/bin/prettier")

vim.api.nvim_create_user_command("W", "write", {})

local format_group = vim.api.nvim_create_augroup("snowden_format", { clear = true })

-- Rather than hand-maintaining a list of extensions, ask prettier what it can parse.
-- --support-info covers ~115 extensions plus extensionless names like .babelrc and
-- package.json. One subprocess per nvim session, then cached.
local prettier_targets

local function prettier_can_format(bufnr)
  if prettier_targets == nil then
    prettier_targets = {}
    local out = vim.fn.system({ vim.g["prettier#exec_cmd_path"], "--support-info" })
    local ok, info = pcall(vim.json.decode, out)
    if vim.v.shell_error == 0 and ok then
      for _, language in ipairs(info.languages or {}) do
        for _, extension in ipairs(language.extensions or {}) do
          prettier_targets[extension] = true
        end
        for _, filename in ipairs(language.filenames or {}) do
          prettier_targets[filename] = true
        end
      end
    end
  end

  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  if prettier_targets[name] then return true end
  -- Try every suffix so multi-dot extensions (.yaml.sed, .component.html) match too.
  local dot = name:find("%.")
  while dot do
    if prettier_targets[name:sub(dot)] then return true end
    dot = name:find("%.", dot + 1)
  end
  return false
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_group,
  pattern = "*",
  callback = function(args)
    if prettier_can_format(args.buf) then vim.cmd("Prettier") end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_group,
  pattern = { "*.cs", "*.razor", "*.rs" },
  callback = function(args)
    -- Without this guard, a buffer whose clients cannot format blocks for the
    -- full timeout on every save.
    local clients = vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/formatting" })
    if #clients == 0 then
      return
    end

    -- In .razor buffers html is attached only to serve roslyn's co-hosting.
    -- It also advertises formatting, and formatting razor with it silently
    -- rewrites `href="@Assets["app.css"]"` to `@Assets[" app.css"]` -- any C#
    -- string nested in an attribute. Never let it format razor, even while
    -- roslyn is still loading the solution.
    local is_razor = vim.bo[args.buf].filetype == "razor"
    vim.lsp.buf.format({
      timeout_ms = 2000,
      filter = function(c) return not (is_razor and c.name == "html") end,
    })
  end,
})
