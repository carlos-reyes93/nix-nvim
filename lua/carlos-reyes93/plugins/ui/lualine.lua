local colorSchemeName = nixCats("colorscheme")

return {
	"lualine.nvim",
	enabled = nixCats("ui"),
	event = "DeferredUIEnter",
	before = function()
		vim.g.startuptime_event_width = 0
		vim.g.startuptime_tries = 10
		vim.g.startuptime_exe_path = nixCats.packageBinPath
	end,
	after = function(_)
		require("lualine").setup({
			options = {
				theme = colorSchemeName,
				icons_enabled = false,
				component_separators = "|",
				section_separators = "",
			},
			sections = {
				lualine_c = {
					{
						"filename",
						path = 1,
						status = true,
					},
				},
			},
			inactive_sections = {
				lualine_b = {
					{
						"filename",
						path = 3,
						status = true,
					},
				},
				lualine_x = { "filetype" },
			},
			tabline = {
				lualine_a = { "buffers" },
				lualine_b = { "lsp_progress" },
				lualine_z = {},
			},
		})
	end,
}
