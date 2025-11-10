return {
	root_dir = function()
		return vim.fn.getcwd()
	end,
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
            disable = { "unused-function" }
		},
	},
}
