local comment = require("Comment.api")

vim.keymap.set("n", "<leader>/", "<Cmd>lua require('Comment.api').toggle.linewise.count(vim.v.count1)<CR>", { silent = true, noremap = true })
vim.keymap.set("x", "<leader>/", "<Cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { silent = true, noremap = true })

