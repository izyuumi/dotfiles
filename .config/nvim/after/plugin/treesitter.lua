local ok, treesitter = pcall(require, "nvim-treesitter.configs")

if not ok then
  return
end

local parser_install_dir = vim.fn.stdpath("data") .. "/site/parser"
vim.fn.mkdir(parser_install_dir, "p")
vim.opt.runtimepath:append(parser_install_dir)

treesitter.setup({
  parser_install_dir = parser_install_dir,
  ensure_installed = { "javascript", "typescript", "lua", "rust", "vim", "c" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})
