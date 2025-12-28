return {
	filetypes = { "lua" },
	settings = {
		Lua = {
			codeLens = { enable = true },
			runtime = {
				version = "LuaJIT",
			},
			telemetry = { enable = false },
			workspace = {
				checkThirdParty = false,
			},
			flags = {
				debounce_text_changes = 0,
			},
			hint = {
				enable = true,
				semicolon = "Disable",
			},
			diagnostics = {
				disable = {
					"unused-local",
					"unused-function",
					"unused-var",
					"unused-param",
				},
			},
		},
	},
}
