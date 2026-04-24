local ok_cmp, cmp = pcall(require, "cmp")
local ok_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local ok_mason, mason = pcall(require, "mason")
local ok_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")

if not (ok_cmp and ok_cmp_nvim_lsp and ok_mason and ok_mason_lspconfig) then
  return
end

if not (vim.lsp and vim.lsp.config and vim.lsp.enable) then
  return
end

mason.setup()
mason_lspconfig.setup({
  ensure_installed = {
    "ts_ls",
    "eslint",
    "rust_analyzer",
  },
  automatic_enable = false,
})

local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = {
  ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
  ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
  ["<CR>"] = cmp.mapping.confirm({ select = true }),
}

cmp.setup({
  mapping = cmp_mappings,
  sources = {
    { name = "nvim_lsp" },
  },
})

local capabilities = cmp_nvim_lsp.default_capabilities()

for _, server in ipairs({ "ts_ls", "eslint", "rust_analyzer", "clangd" }) do
  vim.lsp.config(server, {
    capabilities = capabilities,
  })
  vim.lsp.enable(server)
end
