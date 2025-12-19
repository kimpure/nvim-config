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
            completion = {
                imports = {
                    enabled = true, -- enable auto imports
                },
            },
            sourcemap = {
                enabled = true,
                autogenerate = true, -- automatic generation when the server is initialized
                rojo_project_file = "default.project.json",
                sourcemap_file = "sourcemap.json",
            },
        },
    },
}
