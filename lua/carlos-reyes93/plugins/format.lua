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
					-- Conform will run multiple formatters sequentially
					-- javascript = { { "prettierd", "prettier" } },
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
