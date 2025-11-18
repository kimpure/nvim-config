return {
	cmd = { "luau-lsp", "lsp" },
	filetypes = { "luau" },
	settings = {
		["luau-lsp"] = {
			platform = { type = "roblox" },
			types = { roblox_security_level = "PluginSecurity" },
		},
		sourcemap = {
			enabled = true,
			autogenerate = true,
			rojo_project_file = "default.project.json",
			sourcemap_file = "sourcemap.json",
		},
	},
}
