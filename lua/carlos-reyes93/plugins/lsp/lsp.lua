-- NOTE: lsp setup via lspconfig
local on_attach = require("carlos-reyes93.plugins.lsp.on_attach")

local servers = {}
-- most don't need much configuration
-- servers.gopls = {}
servers.html = {}
servers.cssls = {}
servers.vtsls = {}
servers.tailwindcss = {}
servers.bacon_ls = {
	init_options = {
		updateOnSave = true,
		updateOnSaveWaitMillis = 1000,
	},
}
servers.taplo = {}

servers.sonarlint = require("carlos-reyes93.plugins.lsp.servers.sonarlint").sonarlint

-- but you can provide some if you want to!
servers.lua_ls = {
	settings = {
		Lua = {
			formatters = {
				ignoreComments = true,
			},
			signatureHelp = { enabled = true },
			diagnostics = {
				globals = { "vim", "nixCats" },
				disable = { "missing-fields" },
			},
		},
	},
}
servers.nixd = require("carlos-reyes93.plugins.lsp.servers.nixd").nixd

vim.lsp.config("*", {
	-- capabilities = capabilities,
	on_attach = on_attach,
})

-- set up the servers to be loaded on the appropriate filetypes!
for server_name, cfg in pairs(servers) do
	vim.lsp.config(server_name, cfg)
	vim.lsp.enable(server_name)
end
