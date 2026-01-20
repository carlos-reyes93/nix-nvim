local bufnr = vim.api.nvim_get_current_buf()
local nmap = function(keys, func, desc)
	if desc then
		desc = "LSP: " .. desc
	end
	vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
end

nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
nmap("gr", function()
	Snacks.picker.lsp_references()
end, "[G]oto [R]eferences")
nmap("gI", function()
	Snacks.picker.lsp_implementations()
end, "[G]oto [I]mplementation")
nmap("<leader>ds", function()
	Snacks.picker.lsp_symbols()
end, "[D]ocument [S]ymbols")
nmap("<leader>ws", function()
	Snacks.picker.lsp_workspace_symbols()
end, "[W]orkspace [S]ymbols")

nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

-- Lesser used LSP functionality
nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
nmap("<leader>wl", function()
	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, "[W]orkspace [L]ist Folders")


nmap("<leader>a", function()
	vim.cmd.RustLsp("codeAction") -- supports rust-analyzer's grouping
	-- or vim.lsp.buf.codeAction() if you don't want grouping.
end, "Code Action")

nmap(
	"K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
	function()
		vim.cmd.RustLsp({ "hover", "actions" })
	end,
	"Hover Action"
)
