local function rojo_project()
	return vim.fs.root(0, function(name)
		return name:match(".+%.project%.json$")
	end)
end

return {
	cmd = { "luau-lsp", "lsp" },
	filetypes = { "luau" },
	settings = {
		["luau-lsp"] = {
			platform = {
				type = "roblox",
			},
			types = {
				roblox_security_level = "PluginSecurity",
			},
		},
		sourcemap = {
			enabled = rojo_project(),
			autogenerate = true, -- automatic generation when the server is initialized
			rojo_project_file = "default.project.json",
			sourcemap_file = "sourcemap.json",
		},
	},
	on_init = function(client)
		client.server_capabilities.diagnosticProvider = nil
	end,
}

