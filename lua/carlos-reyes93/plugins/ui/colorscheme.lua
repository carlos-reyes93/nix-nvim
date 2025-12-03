require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	float = {
		transparent = true,
		solid = false,
	},
	styles = {
		keywords = { "bold" },
	},
	custom_highlights = function(colors)
		return {
			-- custom
			PanelHeading = {
				fg = colors.lavender,
				bg = colors.none,
				style = { "bold", "italic" },
			},

			FloatBorder = {
				fg = colors.blue,
				bg = colors.none,
			},

			FloatTitle = {
				fg = colors.lavender,
				bg = colors.none,
			},
		}
	end,
	default_integrations = true,
	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		notify = true,
		mini = {
			enabled = true,
			indentscope_color = "",
		},
		blink_cmp = {
			enabled = true,
			style = "bordered",
		},
		which_key = true,
		snacks = { enabled = true, indent_scope_color = "overlay2" },
	},
})

-- setup must be called before loading
vim.cmd.colorscheme("catppuccin")
