vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>w", vim.cmd.w)
vim.keymap.set("n", "<leader>rr", "<CMD>lua vim.lsp.buf.rename()<CR>")
vim.keymap.set("n", "<leader>la", "<CMD>lua vim.lsp.buf.code_action()<CR>")

-- move code chunks
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", "\"_dP")

-- <leader>y for copying to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- tab and shift-tab code chunks
local noremapsilent = { noremap = true, silent = true }
vim.keymap.set("n", "<Tab>", ">>", noremapsilent)
vim.keymap.set("n", "<S-Tab>", "<<", noremapsilent)
vim.keymap.set("v", "<Tab>", ">gv", noremapsilent)
vim.keymap.set("v", "<S-Tab>", "<gv", noremapsilent)

-- buffer
vim.keymap.set("n", "<leader>c", "<CMD>bd<CR>", noremapsilent)
vim.keymap.set("n", "[b", function()
	return "<CMD>" .. vim.v.count .. "bp<CR>"
end, { noremap = true, silent = true, expr = true })
vim.keymap.set("n", "]b", function()
	return "<CMD>" .. vim.v.count .. "bn<CR>"
end, { noremap = true, silent = true, expr = true })
