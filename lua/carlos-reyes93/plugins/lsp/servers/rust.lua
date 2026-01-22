require("lze").load({
	{
		"rustaceanvim",
		for_cat = "rust",
		ft = { "rust" },
		lazy = false,
		init = function(_)
			vim.g.rustaceanvim = {
				server = {
					on_attach = require("carlos-reyes93.plugins.lsp.on_attach"),
					default_settings = {
						["rust-analyzer"] = {
							cargo = {
								allFeatures = true,
								loadOutDirsFromCheck = true,
								buildScripts = {
									enable = true,
								},
							},
							checkOnSave = {
								enable = false,
							},
							diagnostics = {
								enable = false,
							},
							procMacro = {
								enable = true,
							},
							files = {
								exclude = {
									".direnv",
									".git",
									".jj",
									".github",
									".gitlab",
									"bin",
									"node_modules",
									"target",
									"venv",
									".venv",
								},
								watcher = "client",
							},
						},
					},
				},
			}
		end,
	},
	{
		"crates.nvim",
		for_cat = "rust",
		event = { "BufRead Cargo.toml" },
		after = function(plugin)
			require("crates").setup({
				completion = {
					crates = {
						enabled = true,
					},
				},
				lsp = {
					enabled = true,
					actions = true,
					completion = true,
					hover = true,
				},
			})
		end,
	},
})
