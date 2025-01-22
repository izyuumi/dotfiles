vim.opt.termguicolors = true
require("bufferline").setup({
	options = {
		diagnostics = "nvim_lsp",
		offsets = {
			{ filetype = "Neotree" }
		},
		show_buffer_close_icons = false,
		show_close_icon = false,
	}
})

