require("nvim-tree").setup({
	view = {
		relativenumber = true,
		float = {
			enable = true
		}
	}
})

vim.keymap.set("n", "<leader>o", "<CMD>NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<leader>e", "<CMD>NvimTreeFocus<CR>", { silent = true })

