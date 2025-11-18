local function rojo_project()
	return vim.fs.root(0, function(name)
		return name:match(".+%.project%.json$")
	end)
end

local project_file = rojo_project() or "default.project.json"

return {
	cmd = { "luau-lsp", "lsp" },
	filetypes = { "luau" },
	settings = {
		["luau-lsp"] = {
			platform = { type = "roblox" },
			types = { roblox_security_level = "PluginSecurity" },
		},
		sourcemap = {
			enabled = project_file ~= nil,
			autogenerate = true,
			rojo_project_file = project_file,
			sourcemap_file = "sourcemap.json",
		},
	},
}
