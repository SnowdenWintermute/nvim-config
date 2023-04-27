function ColorMyPencils(color)
	color = color or "sherbet"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "#132025" })
end

ColorMyPencils()
