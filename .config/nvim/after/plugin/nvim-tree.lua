require("nvim-tree").setup({
	view = {
		relativenumber = true,
		float = {
			enable = true
		}
	},
  filters = {
    custom = {
      ".DS_Store"
    }
  }
})

vim.keymap.set("n", "<leader>o", "<CMD>NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<leader>e", "<CMD>NvimTreeFocus<CR>", { silent = true })

local api = require("nvim-tree.api")
api.events.subscribe(api.events.Event.FileCreated, function(file)
  vim.cmd("edit " .. vim.fn.fnameescape(file.fname))
end)
