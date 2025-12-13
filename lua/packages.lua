pack.add({
    { src = "github.com/onsails/lspkind.nvim" },
    { src = "github.com/hrsh7th/cmp-nvim-lsp" },
    { src = "github.com/hrsh7th/cmp-cmdline" },
    { src = "github.com/hrsh7th/cmp-path" },
    { src = "github.com/hrsh7th/cmp-buffer" },
    {
        src = "github.com/hrsh7th/nvim-cmp",
        events = {
            "InsertEnter",
            "CmdlineEnter",
            "BufReadPre",
        },
        boot = function()
            require("config.cmp")
        end,
    },

    { src = "github.com/lopi-py/luau-lsp.nvim" },
    {
        src = "github.com/mason-org/mason.nvim",
        boot = { "mason" },
    },
    { src = "github.com/mason-org/mason-registry" },
    {
        src = "github.com/neovim/nvim-lspconfig",
        import = function()
            vim.lsp.servers = {
                "clangd",
                "lua_ls",
                "rust_analyzer",
                "ts_ls",
                "vimls",
                "jsonls",
            }
            vim.lsp.linters = {
                "eslint_d",
            }
            vim.lsp.formatters = {
                "prettierd",
            }
        end,
        boot = function()
            require("config.lsp")
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
            require("config.tree")
        end,
    },

    {
        src = "github.com/nvim-lualine/lualine.nvim",
        boot = {
            "lualine",
            sections = {
                lualine_c = { "lsp_progress" },
            },
        },
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
            cmdline_type = {
                ":",
                "/",
                "?",
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
        src = "github.com/nacro90/numb.nvim",
        boot = { "numb" },
    },

    {
        src = "github.com/windwp/nvim-autopairs",
        events = { "InsertEnter" },
        boot = { "nvim-autopairs" },
    },
    {
        src = "github.com/kimpure/warp.nvim",
        boot = {
            "warp",
        },
        keymaps = {
            ["'"] = {
                mode = "v",
                cmd = "<CMD>WarpVisual '<CR>",
            },
            ['"'] = {
                mode = "v",
                cmd = '<CMD>WarpVisual "<CR>',
            },
            ["("] = {
                mode = "v",
                cmd = "<CMD>WarpVisual ( )<CR>",
            },
            ["{"] = {
                mode = "v",
                cmd = "<CMD>WarpVisual { }<CR>",
            },
            ["["] = {
                mode = "v",
                cmd = "<CMD>WarpVisual [ ]<CR>",
            },
        },
    },

    {
        src = "https://github.com/willothy/flatten.nvim",
        boot = { "flatten" },
    },

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
    {
        src = "github.com/navarasu/onedark.nvim",
        boot = "colorscheme onedark",
    },

    {
        src = "https://github.com/dmtrKovalenko/fff.nvim",
        import = function()
            local download = require("fff.download")

            if vim.fn.filereadable(download.get_binary_path()) ~= 1 then
               download.download_or_build_binary()
            end
        end,
        boot = {
            "fff",
            hl = {
                border = "none",
            },
        },
        keymaps = {
            ['ff'] = {
                mode = "n",
                cmd = "<CMD>FFFFind<CR>",
            },
        }
    },

    {
        -- dir = "~/dev/savepage.nvim",
        src = "github.com/kimpure/savepage.nvim",
        boot = {
            "savepage",
        }
    }
})
