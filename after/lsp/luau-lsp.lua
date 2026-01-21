local ignore_globs = {
	"**/.pesde/**",
	"node_modules/**",
}

return {
	settings = {
		["luau-lsp"] = {
			ignoreGlobs = ignore_globs,
			completion = {
				imports = { ignoreGlobs = ignore_globs },
				addParentheses = false,
				fillCallArguments = false,
			},
			inlayHints = {
				functionReturnTypes = true,
				parameterTypes = true,
			},
		},
	},
}
