local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed {
  "ts_ls",
  "eslint",
  "rust_analyzer"
}

local cmp = require("cmp")
local cmp_select = { behaviro = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
  ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
  ["<CR>"] = cmp.mapping.confirm({ select = true }),
})

cmp.config.sources({
	{ name = 'nvim_lsp' },
})

lsp.set_preferences({
  sign_icons = { }
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.setup()
