local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = "Find by word (live grep)" })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Find keymaps" })

