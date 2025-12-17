require("lze").load({
	{
		"conform.nvim",
		enabled = nixCats("format"),
		after = function(_)
			local conform = require("conform")
			conform.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					nix = { "alejandra" },
					javascript = { "prettierd" },
					typescript = { "prettierd" },
					javascriptreact = { "prettierd" },
					typescriptreact = { "prettierd" },
					svelte = { "prettierd" },
					css = { "prettierd" },
					html = { "prettierd" },
					json = { "prettierd" },
					yaml = { "prettierd" },
				},
			})
			vim.keymap.set({ "n", "v" }, "<leader>FF", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end, { desc = "[F]ormat [F]ile" })
		end,
	},
})
