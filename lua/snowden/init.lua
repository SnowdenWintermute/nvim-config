require("snowden.remap")
require("snowden.set")

--vim.cmd "colorscheme blue"
vim.cmd "colorscheme vscode"
vim.cmd "set cc="
vim.o.mouse = 'a'

-- don't jump to definition of constructors, just go to the export line
vim.lsp.handlers["textDocument/definition"] = function(_, result, ctx, _)
  if not result or vim.tbl_isempty(result) then
    vim.notify("No definition found", vim.log.levels.WARN)
    return
  end

  local function get_range(loc)
    return loc.range or loc.targetRange
  end

  local function get_uri(loc)
    return loc.uri or loc.targetUri
  end

  local function is_constructor(loc)
    local uri = get_uri(loc)
    local range = get_range(loc)
    if not uri or not range then
      return false
    end
    local filename = vim.uri_to_fname(uri)
    local lines = vim.fn.readfile(filename, '', range.start.line + 1)
    local line = lines[range.start.line + 1] or ''
    return line:match('constructor')
  end

  local locations = vim.tbl_islist(result) and result or {result}

  local filtered = vim.tbl_filter(function(loc)
    return not is_constructor(loc)
  end, locations)

  local target = #filtered > 0 and filtered[1] or locations[1]
  vim.lsp.util.jump_to_location(target, "utf-8")
end

