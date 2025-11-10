local create_autocmd = vim.api.nvim_create_autocmd

create_autocmd("LspAttach", {
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

create_autocmd("VimEnter", {
	callback = function()
        local lsp_servers = vim.lsp.servers
		for i = 1, #lsp_servers do
			vim.lsp.enable(lsp_servers[i])
		end
	end,
})

create_autocmd("ExitPre", {
	pattern = "*",
	callback = function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			--- @diagnostic disable-next-line
			if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
	end,
})
