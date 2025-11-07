pack.add({
	{ src = "github.com/lopi-py/luau-lsp.nvim" },
	{ src = "github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "github.com/mason-org/mason.nvim" },
	{
		src = "github.com/neovim/nvim-lspconfig",
		boot = function()
			local lsp_servers = {
				"clangd",
				"lua_ls",
				"rust_analyzer",
				"vimls",
				"luau_lsp",
			}

			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = lsp_servers,
				automatic_installation = true,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
			capabilities.workspace = {
				didChangeWatchedFiles = {
					dynamicRegistration = true,
				},
			}

			vim.lsp.config("*", {
				capabilities = capabilities,
				flags = {
					debounce_text_changes = 200,
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp_buf_conf", { clear = true }),
				callback = function(event_context)
					local client = vim.lsp.get_client_by_id(event_context.data.client_id)

					if not client then
						return
					end

					local bufnr = event_context.buf

					vim.keymap.set("n", "gd", function()
						vim.lsp.buf.definition({
							on_list = function(options)
								local unique_defs = {}
								local def_loc_hash = {}

								for _, def_location in pairs(options.items) do
									local hash_key = def_location.filename .. def_location.lnum

									if not def_loc_hash[hash_key] then
										def_loc_hash[hash_key] = true
										table.insert(unique_defs, def_location)
									end
								end

								options.items = unique_defs

								vim.fn.setloclist(0, {}, " ", options)

								if #options.items > 1 then
									vim.cmd.lopen()
								else
									vim.cmd([[silent! lfirst]])
								end
							end,
						})
					end, {
						silent = true,
						buffer = bufnr,
						desc = "go to definition",
					})

					vim.keymap.set("n", "K", function()
						vim.lsp.buf.hover({
							border = "solid",
							max_height = 20,
							max_width = 130,
							close_events = { "CursorMoved", "BufLeave", "WinLeave", "LSPDetach" },
						})
					end, {
						silent = true,
						buffer = event_context.buf,
					})

					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, {
						silent = true,
						buffer = bufnr,
					})
				end,
				nested = true,
			})

			local function lsp_attach()
				for i = 1, #lsp_servers do
					local server_name = lsp_servers[i]

					vim.lsp.config(server_name, {
						capabilities = capabilities,
						flags = { debounce_text_changes = 300 },
					})

					vim.lsp.enable(server_name)
				end
			end

			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					lsp_attach()
				end,
			})
		end,
	},

	{
		src = "github.com/folke/lazydev.nvim",
		boot = {
			"lazydev",
			library = {
				{
					path = "${3rd}/luv/library",
					words = { "vim%.uv" },
				},
			},
		},
	},
	{ src = "github.com/onsails/lspkind.nvim" },
	{ src = "github.com/hrsh7th/cmp-nvim-lsp" },
	{ src = "github.com/hrsh7th/cmp-cmdline" },
	{ src = "github.com/hrsh7th/cmp-path" },
	{ src = "github.com/hrsh7th/cmp-buffer" },
	{
		src = "github.com/hrsh7th/nvim-cmp",
		boot = function()
			local cmp = require("cmp")

			require("cmp_nvim_lsp")
			require("cmp_path")
			require("cmp_buffer")
			require("cmp_cmdline")

			local lspkind = require("lspkind")

			cmp.setup({
				preselect = cmp.PreselectMode.None,
				performance = {
					debounce = 0,
					throttle = 0,
					fetching_timeout = 100,
					filtering_context_budget = 3,
					confirm_resolve_timeout = 80,
					async_budget = 1,
					max_view_entries = 25,
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
				sources = {
					{ name = "nvim_lsp" },
					{ name = "path" },
					{
						name = "buffer",
						keyword_length = 2,
					},
					{
						name = "lazydev",
						group_index = 0,
					},
				},
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
					format = lspkind.cmp_format({
						mode = "symbol", -- show only symbol annotations
						maxwidth = {
							menu = 50, -- leading text (labelDetails)
							abbr = 50, -- actual suggestion item
						},
						ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
						show_labelDetails = true, -- show labelDetails in menu. Disabled by default
						symbol_map = {
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
						},
					}),
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
			})
		end,
	},

	{
		src = "github.com/2KAbhishek/nerdy.nvim",
		boot = {
			"nerdy",
			max_recents = 30,
		},
	},
	{
		src = "github.com/DaikyXendo/nvim-material-icon",
		boot = {
			"nvim-web-devicons",
			override_by_filename = {
				[".luaurc"] = {
					icon = "",
					color = "#007ABF",
					name = "Luaurc",
				},
				["LICENCE"] = {
					icon = "󰄤",
					color = "#ec6237",
					cterm_color = "220",
					name = "LICENSE",
				},
				["LICENCE.md"] = {
					icon = "󰄤",
					color = "#ec6237",
					cterm_color = "220",
					name = "LICENSE",
				},
			},
		},
	},

	{ src = "github.com/kimpure/trash.nvim" },
	{ src = "github.com/nvim-lua/plenary.nvim" },
	{
		src = "github.com/nvim-tree/nvim-tree.lua",
		boot = function()
			local api = require("nvim-tree.api")
			local nvim_tree = require("nvim-tree")
			local trash_file = require("trash").setup().trash_file

			--- @param bufnr integer
			local function on_attach(bufnr)
				local function opts(desc)
					return {
						desc = "nvim-tree: " .. desc,
						buffer = bufnr,
						noremap = true,
						silent = true,
						nowait = true,
					}
				end

				local function open_node(...)
					local node = api.tree.get_node_under_cursor()

					--// Blocked root_folder_label
					if not node or not node.parent then
						return
					end

					api.node.open.edit(...)
				end

				local function root_to_node(...)
					local node = api.tree.get_node_under_cursor()

					--// Blocked root_folder_label
					if not node or not node.parent then
						return
					end

					api.tree.change_root_to_node(...)
				end

				local function remove()
					if vim.g.is_windows then
						local node = api.tree.get_node_under_cursor()
						local lower = string.lower

						if not node or not node.absolute_path then
							return
						end

						if nvim_tree.config.ui.confirm.default_yes then
							local confirm = vim.fn.input("Remove " .. node.name .. "? Y/n: ")

							if confirm ~= "" and lower(confirm) ~= "y" then
								return
							end

							utils.fs.remove_file(node.absolute_path)

							api.tree.reload()
						else
							local confirm = vim.fn.input("Remove " .. node.name .. "? y/N: ")

							if lower(confirm) ~= "y" then
								return
							end

							utils.fs.remove_file(node.absolute_path)

							api.tree.reload()
						end
					else
						api.fs.remove()
					end
				end

				local function trash()
					local node = api.tree.get_node_under_cursor()
					local lower = string.lower

					if not node or not node.absolute_path then
						return
					end

					if nvim_tree.config.ui.confirm.default_yes then
						local confirm = vim.fn.input("Trash " .. node.name .. "? Y/n: ")

						if confirm ~= "" and lower(confirm) ~= "y" then
							return
						end

						trash_file(node.absolute_path)
						api.tree.reload()
					else
						local confirm = vim.fn.input("Trash " .. node.name .. "? y/N: ")

						if lower(confirm) ~= "y" then
							return
						end

						trash_file(node.absolute_path)
						api.tree.reload()
					end
				end

				vim.keymap.set("n", ".", root_to_node, opts("CD"))
				vim.keymap.set("n", "<BS>", api.tree.change_root_to_parent, opts("Up"))

				-- vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("CD"))
				vim.keymap.set("n", "<C-e>", api.node.open.replace_tree_buffer, opts("Open: In Place"))
				vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("Info"))
				vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("Rename: Omit Filename"))
				vim.keymap.set("n", "<C-t>", api.node.open.tab, opts("Open: New Tab"))
				vim.keymap.set("n", "<C-v>", api.node.open.vertical, opts("Open: Vertical Split"))
				vim.keymap.set("n", "<C-x>", api.node.open.horizontal, opts("Open: Horizontal Split"))
				-- vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
				-- vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))

				vim.keymap.set("n", "<CR>", open_node, opts("Open"))

				vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("Open Preview"))
				vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("Next Sibling"))
				vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("Previous Sibling"))
				-- vim.keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
				-- vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
				vim.keymap.set("n", "a", api.fs.create, opts("Create File Or Directory"))
				vim.keymap.set("n", "bd", api.marks.bulk.delete, opts("Delete Bookmarked"))
				vim.keymap.set("n", "bt", api.marks.bulk.trash, opts("Trash Bookmarked"))
				vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("Move Bookmarked"))
				vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("Toggle Filter: No Buffer"))
				vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy"))
				vim.keymap.set("n", "C", api.tree.toggle_git_clean_filter, opts("Toggle Filter: Git Clean"))
				vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("Prev Git"))
				vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("Next Git"))
				vim.keymap.set("n", "d", remove, opts("Delete"))
				vim.keymap.set("n", "D", trash, opts("Trash"))
				vim.keymap.set("n", "E", api.tree.expand_all, opts("Expand All"))
				vim.keymap.set("n", "e", api.fs.rename_basename, opts("Rename: Basename"))
				vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("Next Diagnostic"))
				vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("Prev Diagnostic"))
				vim.keymap.set("n", "F", api.live_filter.clear, opts("Live Filter: Clear"))
				vim.keymap.set("n", "f", api.live_filter.start, opts("Live Filter: Start"))
				vim.keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
				vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
				vim.keymap.set("n", "ge", api.fs.copy.basename, opts("Copy Basename"))
				vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
				vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
				vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("Last Sibling"))
				vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("First Sibling"))
				vim.keymap.set("n", "L", api.node.open.toggle_group_empty, opts("Toggle Group Empty"))
				vim.keymap.set("n", "M", api.tree.toggle_no_bookmark_filter, opts("Toggle Filter: No Bookmark"))
				vim.keymap.set("n", "m", api.marks.toggle, opts("Toggle Bookmark"))
				vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
				vim.keymap.set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))
				vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
				vim.keymap.set("n", "P", api.node.navigate.parent, opts("Parent Directory"))
				vim.keymap.set("n", "q", api.tree.close, opts("Close"))
				vim.keymap.set("n", "r", api.fs.rename, opts("Rename"))
				vim.keymap.set("n", "R", api.tree.reload, opts("Refresh"))
				vim.keymap.set("n", "s", api.node.run.system, opts("Run System"))
				vim.keymap.set("n", "S", api.tree.search_node, opts("Search"))
				vim.keymap.set("n", "u", api.fs.rename_full, opts("Rename: Full Path"))
				vim.keymap.set("n", "U", api.tree.toggle_custom_filter, opts("Toggle Filter: Hidden"))
				vim.keymap.set("n", "W", api.tree.collapse_all, opts("Collapse All"))
				vim.keymap.set("n", "x", api.fs.cut, opts("Cut"))
				vim.keymap.set("n", "y", api.fs.copy.filename, opts("Copy Name"))
				vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("Copy Relative Path"))
				vim.keymap.set("n", "<2-LeftMouse>", open_node, opts("Open"))
				vim.keymap.set("n", "<2-RightMouse>", root_to_node, opts("CD"))
			end

			nvim_tree.setup({
				auto_reload_on_write = true,
				disable_netrw = false,
				hijack_netrw = true,
				hijack_cursor = false,
				hijack_unnamed_buffer_when_opening = false,
				open_on_tab = false,
				update_cwd = false,
				view = {
					width = 30,
					side = "left",
					preserve_window_proportions = false,
					number = false,
					relativenumber = false,
					signcolumn = "yes",
				},
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
				hijack_directories = {
					enable = true,
					auto_open = true,
				},
				update_focused_file = {
					enable = false,
					update_cwd = false,
					ignore_list = {},
				},
				system_open = {
					cmd = "",
					args = {},
				},
				filters = {
					dotfiles = false,
					custom = { "^\\.git$" },
					exclude = {},
				},
				git = {
					enable = true,
					ignore = false,
					timeout = 400,
				},
				actions = {
					use_system_clipboard = true,
					change_dir = {
						enable = false,
						global = false,
						restrict_above_cwd = false,
					},
					remove_file = {
						close_window = false,
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
				trash = {
					cmd = "trash",
					require_confirm = true,
				},
				log = {
					enable = false,
					truncate = false,
				},

				-- Use this when NvimTree is too slow.
				-- filesystem_watchers = {
				--     enable = false,
				-- },

				on_attach = on_attach,
			})

			vim.keymap.set("n", "<space>e", api.tree.toggle, {
				silent = true,
				desc = "toggle nvim-tree",
			})
		end,
	},

	{
		src = "github.com/hedyhli/outline.nvim",
		boot = {
			"outline",
		},
	},

	{
		src = "github.com/kimpure/cmdhistory.nvim",
		boot = {
			"cmdhistory",
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
		},
	},

	{
		src = "github.com/numToStr/FTerm.nvim",
		boot = {
			"FTerm",
			ft = "FTerm",
			cmd = vim.o.shell,
			border = "none",
			dimensions = {
				height = 0.9,
				width = 0.9,
			},
			auto_close = true,
		},
		keymaps = {
			["<C-\\>"] = {
				mode = { "n", "t" },
				cmd = '<CMD>lua require("FTerm").toggle()<CR>',
			},
		},
	},

	{
		src = "github.com/lewis6991/gitsigns.nvim",
		boot = {
			"gitsigns",
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
		},
	},

	{
		src = "github.com/lukas-reineke/indent-blankline.nvim",
		boot = { "ibl" },
	},

	{
		src = "github.com/windwp/nvim-autopairs",
		event = "InsertEnter",
		boot = { "nvim-autopairs" },
	},

	{ src = "github.com/samjwill/nvim-unception" },

	{
		src = "github.com/lewis6991/satellite.nvim",
		boot = {
			"satellite",
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
		},
	},

	{
		src = "github.com/vyfor/cord.nvim",
		boot = function()
			require("cord").setup({
				idle = {
					enabled = false,
				},
			})
			vim.cmd("Cord update")
		end,
	},

	{
		src = "github.com/kimpure/transparent.nvim",
		boot = {
			"transparent",
		},
		disable = true,
	},
	{
		src = "github.com/kimpure/gitcolors.nvim",
		boot = {
			"gitcolors",
		},
	},
	{ src = "github.com/rktjmp/lush.nvim" },
	{
		src = "github.com/kimpure/sakura.nvim",
		boot = function()
			vim.cmd.colorscheme("sakura")
		end,
		disable = true,
	},
	{
		src = "github.com/navarasu/onedark.nvim",
		boot = function()
			require("onedark").setup({
				style = "dark",
			})

			vim.cmd("colorscheme onedark")
		end,
	},
})
