local plugin = packages.plugin

-- Plenary
plugin.install("nvim-lua/plenary.nvim")

-- FileTree
plugin.install("2KAbhishek/nerdy.nvim")
plugin.install("DaikyXendo/nvim-material-icon")
plugin.install("nvim-tree/nvim-tree.lua")("nvim-tree").setup({
	renderer = {
		special_files = {},
		highlight_git = true,
		root_folder_label = ":~:s?$?",
		indent_markers = {
			enable = false,
		},
		icons = {
			webdev_colors = true,
			show = {
				git = false,
			},
		},
	},
	diagnostics = {
		enable = true,
		show_on_dirs = true,
		icons = {
			hint = "H",
			info = "I",
			warning = "W",
			error = "E",
		},
	},
	log = {
		enable = false,
		truncate = false,
	},
})
vim.keymap.set("n", "<space>e", require("nvim-tree.api").tree.toggle, {
	silent = true,
	desc = "Toggle nvim-tree",
})

-- Cmp
local cmp = plugin.install("hrsh7th/nvim-cmp")("cmp")

plugin.install("hrsh7th/cmp-cmdline")("cmp_cmdline")
plugin.install("hrsh7th/cmp-path")("cmp_path")
plugin.install("hrsh7th/cmp-buffer")("cmp_buffer")
plugin.install("hrsh7th/cmp-nvim-lsp")("cmp_nvim_lsp")

local icons = {
	Text = "",
	Method = "",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "",
	Interface = "",
	Module = "",
	Property = "",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

cmp.setup({
	preselect = cmp.PreselectMode.None,
	performance = {
		debounce = 0,
		throttle = 0,
		fetching_timeout = 100,
		filtering_context_budget = 3,
		confirm_resolve_timeout = 80,
		async_budget = 1,
		max_view_entries = 50,
	},
	mapping = cmp.mapping.preset.insert({
		["<Down>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
			else
				fallback()
			end
		end, { "i", "s" }),
		["<Up>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
			else
				fallback()
			end
		end, { "i", "s" }),
		["<Tab>"] = function(fallback)
			if cmp.visible() and cmp.get_selected_entry() then
				cmp.confirm({ select = false })
			else
				fallback()
			end
		end,
		["<C-e>"] = cmp.mapping.abort(),
		["<Esc>"] = cmp.mapping.close(),
	}),
	completion = {
		keyword_length = 1,
		completeopt = "menu,menuone,noselect,noinsert",
	},
	window = {
		completion = cmp.config.window.bordered({
			border = "none",
		}),
		documentation = cmp.config.window.bordered({
			border = "none",
		}),
	},
	view = {
		entries = "custom",
	},
	formatting = {
		fields = { "abbr", "kind" },
		format = function(_, item)
			item.kind = icons[item.kind] or ""
			return item
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "path" },
		{ name = "buffer", keyword_length = 2 },
	},
	sorting = {
		priority_weight = 1000,
		comparators = {
			cmp.config.compare.score,
			cmp.config.compare.exact,
			cmp.config.compare.offset,
			cmp.config.compare.sort_text,
			cmp.config.compare.kind,
			cmp.config.compare.length,
			cmp.config.compare.order,
		},
	},
})
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
    matching = { disallow_symbol_nonprefix_matching = false },
})

-- Lsp
plugin.install("neovim/nvim-lspconfig")
plugin.install("mason-org/mason.nvim")
plugin.install("mason-org/mason-registry")
plugin.install("lopi-py/luau-lsp.nvim")

require("mason").setup()
local registry = require("mason-registry")

for i = 1, #vim.lsp.servers do
	local success, pkg = pcall(registry.get_package, vim.lsp.servers[i])

	if success and not pkg:is_installed() then
		pkg:install()
	end
end

for i = 1, #vim.lsp.formatters do
	local success, pkg = pcall(registry.get_package, vim.lsp.formatters[i])

	if success and not pkg:is_installed() then
		pkg:install()
	end
end

for i = 1, #vim.lsp.linters do
	local success, pkg = pcall(registry.get_package, vim.lsp.linters[i])

	if success and not pkg:is_installed() then
		pkg:install()
	end
end

vim.lsp.config("*", {
	capabilities = {
		textDocument = {
			completion = {
				dynamicRegistration = false,
				completionItem = {
					snippetSupport = true,
					commitCharactersSupport = true,
					deprecatedSupport = true,
					preselectSupport = true,
					tagSupport = {
						valueSet = {
							1, -- Deprecated
						},
					},
					insertReplaceSupport = true,
					resolveSupport = {
						properties = {
							"documentation",
							"additionalTextEdits",
							"insertTextFormat",
							"insertTextMode",
							"command",
						},
					},
					insertTextModeSupport = {
						valueSet = {
							1, -- asIs
							2, -- adjustIndentation
						},
					},
					labelDetailsSupport = true,
				},
				contextSupport = true,
				insertTextMode = 1,
				completionList = {
					itemDefaults = {
						"commitCharacters",
						"editRange",
						"insertTextFormat",
						"insertTextMode",
						"data",
					},
				},
			},
		},
	},
	flags = {
		debounce_text_changes = 200,
	},
})

vim.lsp.enable(vim.lsp.servers)

-- Terminal
plugin.install("willothy/flatten.nvim")("flatten").setup()

-- TabLine
plugin.install("lukas-reineke/indent-blankline.nvim")("ibl").setup()

-- Scroll
plugin.install("lewis6991/satellite.nvim")("satellite").setup({
	current_only = false,
	winblend = 0,
	handlers = {
		gitsigns = {
			signs = {
				add = "│",
				change = "│",
				delete = "│",
			},
		},
	},
})

-- ColorScheme
plugin.install("navarasu/onedark.nvim")("onedark").setup({
    style = "darker",
})

