vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
	view = {
		relativenumber = true,
		float = {
			enable = true,
		},
	},
	filters = {
		dotfiles = false,
		git_ignored = false,
		custom = {
			".DS_Store",
		},
	},
	lazy = false,
	update_cwd = false,
})

vim.keymap.set("n", "<leader>o", "<CMD>NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<leader>e", "<CMD>NvimTreeFocus<CR>", { silent = true })

local api = require("nvim-tree.api")
api.events.subscribe(api.events.Event.FileCreated, function(file)
	vim.cmd("edit " .. vim.fn.fnameescape(file.fname))
end)
