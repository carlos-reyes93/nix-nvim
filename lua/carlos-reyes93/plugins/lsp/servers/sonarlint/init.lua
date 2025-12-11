local M = {}
local sonarlintStorePath = vim.fn.exepath("sonarlint-ls")
local nodePath = vim.fn.exepath("node")
require("carlos-reyes93.plugins.lsp.servers.sonarlint.rules")
M.handlers = {}

M.handlers["sonarlint/isOpenInEditor"] = function()
	return true
end

M.handlers["sonarlint/shouldAnalyzeFile"] = function()
	return { shouldBeAnalyzed = true }
end

M.handlers["sonarlint/filterOutExcludedFiles"] = function(_, params, _, _)
	return params
end

M.handlers["sonarlint/listFilesInFolder"] = function(_, params, _, _)
	local folder = vim.uri_to_fname(params.folderUri)
	local files = vim.fs.dir(folder)

	local result = {
		foundFiles = {},
	}

	for path, t in files do
		if t == "file" then
			table.insert(result.foundFiles, { fileName = path, filePath = folder })
		end
	end
	return result
end

M.handlers["sonarlint/canShowMissingRequirementsNotification"] = function ()
  return false
end

-- M.handlers["sonarlint/showRuleDescription"] = require("carlos-reyes93.plugins.lsp.servers.sonarlint.rules").show_rule_handler
M.sonarlint = {
	cmd = { sonarlintStorePath },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	root_markers = { ".git", "tsconfig.json", "package.json" },
	settings = {
		sonarlint = {
			rules = {
				["javascript:S100"] = { level = "on" },
			},
		},
	},
	init_options = {
		productKey = "sonarqube",
		productName = "sonarqube",
		architecture = vim.loop.os_uname().machine,
		firstSecretDetected = false,
		platform = vim.loop.os_uname().sysname,
		productVersion = "0.0.1",
		showVerboseLogs = true,
		workspaceName = vim.fn.getcwd(),
    clientNodePath = nodePath
	},
  handlers = M.handlers
}

return M
