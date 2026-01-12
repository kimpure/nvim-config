local plugin = packages.plugin

-- Plenary
plugin.install("nvim-lua/plenary.nvim")

-- FileTree
plugin.install("2KAbhishek/nerdy.nvim")
plugin.install("DaikyXendo/nvim-material-icon")

local nvim_tree = plugin.install("nvim-tree/nvim-tree.lua")("nvim-tree")
local nvim_tree_api = require("nvim-tree.api")
local nvim_tree_view = require("nvim-tree.view")

nvim_tree.setup({
	auto_reload_on_write = true,
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
	actions = {
		remove_file = {
			close_window = true,
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
	git = {
		ignore = false,
	},
	filters = {
		custom = { "^\\.git$" },
	},
	log = {
		enable = false,
		truncate = false,
	},
	on_attach = function(bufnr)
		nvim_tree_api.config.mappings.default_on_attach(bufnr)

		vim.keymap.set("n", "d", function()
			--- @type nvim_tree.api.Node
			local node = nvim_tree_api.tree.get_node_under_cursor()

			if not node or not node.absolute_path then
				return
			end

			local confirm = vim.fn.input("Remove " .. node.name .. "? y/N: ")

			if string.lower(confirm) ~= "y" then
				return
			end

			vim.fn.delete(node.absolute_path, "rf")

			local function close_windows(windows)
				-- Prevent from closing when the win count equals 1 or 2,
				-- where the win to remove could be the last opened.
				-- For details see #2503.
				if nvim_tree_view.View.float.enable and #vim.api.nvim_list_wins() < 3 then
					return
				end

				for _, window in ipairs(windows) do
					if vim.api.nvim_win_is_valid(window) then
						vim.api.nvim_win_close(window, true)
					end
				end
			end

			local function clear_buffer(absolute_path)
				local bufs = vim.fn.getbufinfo({ bufloaded = 1, buflisted = 1 })
				for _, buf in pairs(bufs) do
					if buf.name == absolute_path then
						local tree_winnr = vim.api.nvim_get_current_win()
						if buf.hidden == 0 and (#bufs > 1 or nvim_tree_view.View.float.enable) then
							vim.api.nvim_set_current_win(buf.windows[1])
							vim.cmd(":bn")
						end
						vim.api.nvim_buf_delete(buf.bufnr, { force = true })
						if not nvim_tree_view.View.float.quit_on_focus_loss then
							vim.api.nvim_set_current_win(tree_winnr)
						end
						close_windows(buf.windows)
						return
					end
				end
			end

			clear_buffer(node.absolute_path)

			nvim_tree_api.tree.reload()
		end, {
			desc = "nvim-tree: Delete",
			buffer = bufnr,
			noremap = true,
			silent = true,
			nowait = true,
		})

		vim.keymap.set("n", "<CR>", function()
			local node = nvim_tree_api.tree.get_node_under_cursor()

			--// Blocked root_folder_label
			if not node or not node.parent then
				return
			end

			nvim_tree_api.node.open.edit()
		end, {
			desc = "nvim-tree: Open",
			buffer = bufnr,
			noremap = true,
			silent = true,
			nowait = true,
		})
	end,
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
plugin.install("folke/lazydev.nvim")("lazydev").setup({
	library = {
		{
			path = "${3rd}/luv/library",
			words = { "vim%.uv" },
		},
	},
})

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

local tab_comp = false

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
				tab_comp = true
			else
				fallback()
				tab_comp = false
			end
		end, { "i", "s" }),
		["<Up>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
				tab_comp = true
			else
				fallback()
				tab_comp = false
			end
		end, { "i", "s" }),
		["<Tab>"] = function(fallback)
			if cmp.visible() then
				if tab_comp and cmp.get_selected_entry() then
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>u", true, true, true), "n", false)
					cmp.confirm({ select = false })
					tab_comp = false
				else
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				end
			else
				fallback()
			end
		end,
		["<S-Tab>"] = function(fallback)
			if cmp.visible() then
				cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
			end
		end,
		["<CR>"] = function(fallback)
			if cmp.get_selected_entry() then
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>u", true, true, true), "n", false)
				cmp.confirm({ select = false })
				tab_comp = false
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
		{ name = "lazydev", group_index = 0 },
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

cmp.setup.filetype("luau", {
	sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer", keyword_length = 2 },
	},
})

-- Syntax
plugin.install("kimpure/blink-syntax.vim")
plugin.install("kimpure/luau-syntax.vim")

-- Lsp
local vscode_settings = plugin.install("kimpure/vscode-settings.nvim")("vscode-settings")

plugin.install("lopi-py/luau-lsp.nvim")("luau-lsp").setup(vim.tbl_deep_extend("force", {
    platform = {
        type = "roblox",
    },
    types = {
        roblox_security_level = "PluginSecurity",
    },
    sourcemap = {
        enabled = true,
        autogenerate = true, -- automatic generation when the server is initialized
        rojo_project_file = "default.project.json",
        sourcemap_file = "sourcemap.json",
    },
}, vscode_settings.get_settings()["luau-lsp"] or {}))

plugin.install("neovim/nvim-lspconfig")
plugin.install("mason-org/mason.nvim")("mason").setup()

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

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		if not client then
			return
		end

		require("cmp").setup.buffer({
			sources = {
				{ name = "nvim_lsp" },
			},
		})
	end,
})

-- Pairs
plugin.install("windwp/nvim-autopairs")("nvim-autopairs").setup()
plugin.install("kimpure/warp.nvim")("warp").setup()

--- Git
plugin.install("lewis6991/gitsigns.nvim")("gitsigns").setup({
	signs = {
		add = { text = "┃" },
		change = { text = "┃" },
		delete = { text = "┃" },
		topdelete = { text = "┃" },
		changedelete = { text = "┃" },
		untracked = { text = "┆" },
	},
	signs_staged = {
		add = { text = "┃" },
		change = { text = "┃" },
		delete = { text = "┃" },
		topdelete = { text = "┃" },
		changedelete = { text = "┃" },
		untracked = { text = "┆" },
	},
})

-- Notify
local notify = plugin.install("rcarriga/nvim-notify")("notify")
notify.setup({
	timeout = 0,
	stages = "fade",
	minimum_width = 30,
	top_down = false,
})
vim.notify = notify

-- Terminal
plugin.install("willothy/flatten.nvim")("flatten").setup()

-- TabLine
plugin.install("lukas-reineke/indent-blankline.nvim")("ibl").setup()

-- Scroll
plugin.install("lewis6991/satellite.nvim")("satellite").setup({
	current_only = false,
	winblend = 0,
	handlers = {
		marks = {
			enable = false,
		},
		gitsigns = {
			enable = true,
			signs = {
				add = "│",
				change = "│",
				delete = "│",
			},
		},
	},
})

-- Cmdline
plugin.install("kimpure/cmdhistory.nvim")("cmdhistory").setup({
	mute = {
		"q",
		"qa",
		"wq",
		"wqa",
		"wincmd h",
		"wincmd j",
		"wincmd k",
		"wincmd l",
		"w",
		"wa",
	},
})

-- ColorScheme
plugin.install("rktjmp/lush.nvim")
plugin.install("kimpure/sakura.nvim")
