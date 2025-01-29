local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = "Find by word (live grep)" })
vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = "Find keymaps" })

local telescope = require('telescope')
telescope.setup({
  defaults = {
    file_ignore_patterns = { 'node_modules', '.git', 'target' },
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
    },
  },
})