local M = {}

---@param buf integer
local function show_in_popup(buf)
	-- Get the dimensions of the current window
	local width = vim.o.columns
	local height = vim.o.lines

	-- Calculate the dimensions for the floating window
	local win_width = math.floor(width * 0.8)
	local win_height = math.floor(height * 0.8)

	-- Calculate the position for the floating window
	local row = math.floor((height - win_height) / 2)
	local col = math.floor((width - win_width) / 2)

	-- Create the floating window
	local opts = {
		style = "minimal",
		relative = "editor",

		width = win_width,
		height = win_height,
		row = row,
		col = col,
		border = "single",
	}

	vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
	vim.api.nvim_create_autocmd({ "BufLeave" }, {
		buffer = buf,
		callback = function()
			vim.api.nvim_buf_delete(buf, {})
		end,
	})

	vim.api.nvim_open_win(buf, true, opts)
end

function M.show_rule_handler(_, result, _)
	print("yoo")
	local utils = require("sonarlint.utils")

	local file_type = vim.api.nvim_get_option_value("filetype", { buf = 0 })
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

	local htmlDescription = result.htmlDescription

	local markdown_lines = {
		"# " .. result.key .. ": " .. result.name,
		"",
	}

	if htmlDescription == nil or htmlDescription == "" then
		for i, htmlDescriptionTab in ipairs(result.htmlDescriptionTabs) do
			if i > 1 then
				vim.list_extend(markdown_lines, {
					"",
				})
			end
			local ruleDescriptionTabHtmlContent = htmlDescriptionTab.ruleDescriptionTabContextual.htmlContent
				or htmlDescriptionTab.ruleDescriptionTabNonContextual.htmlContent

			vim.list_extend(markdown_lines, {
				"## " .. htmlDescriptionTab.title,
				"",
			})
			vim.list_extend(markdown_lines, utils.html_to_markdown_lines(ruleDescriptionTabHtmlContent, file_type))
		end
	else
		markdown_lines = utils.html_to_markdown_lines(htmlDescription, file_type)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, markdown_lines)
	vim.api.nvim_set_option_value("readonly", true, { buf = buf })
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	show_in_popup(buf)
end

function M.list_all_rules()
	local clients = vim.lsp.get_clients({ name = "sonarlint", bufnr = 0 })

	if #clients ~= 1 then
		vim.notify("Found more then one attached Sonarlint client. That shouldn't be possible", vim.log.levels.ERROR)
		return
	end

	clients[1]:request("sonarlint/listAllRules", {}, function(err, result)
		if err then
			vim.notify("Cannot request the list of rules: " .. err, vim.log.levels.ERROR)
			return
		end
		local buf = vim.api.nvim_create_buf(false, true)

		for language, rules in pairs(result) do
			print(language)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "# " .. language, "" })

			for _, rule in ipairs(rules) do
				local line = { " - ", rule.key, ": ", rule.name }

				if rule.activeByDefault then
					line[#line + 1] = " (active by default)"
				end
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, { table.concat(line, "") })
			end
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
		end

		vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })

		vim.api.nvim_set_option_value("readonly", true, { buf = buf })

		vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

		show_in_popup(buf)
	end)
end

vim.api.nvim_create_user_command("SonarlintListRules", M.list_all_rules, {})

return M
