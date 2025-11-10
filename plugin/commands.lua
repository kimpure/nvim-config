local api = vim.api
local fn = vim.fn
local create_user_command = api.nvim_create_user_command

create_user_command("Pack", function(opts)
	local fargs = opts.fargs
	local command = fargs[1]
	local target = utils.lua.table_select(2, fargs)

	if command == "update" then
		pack.update(target)
	elseif command == "del" then
		pack.del(target)
	elseif command == "unload" then
		pack.unload(target)
	elseif command == "list" then
		print(utils.lua.tostring(pack.list()))
	else
		vim.notify("Unknown argument: " .. command, vim.log.levels.WARN)
	end
end, {
	nargs = "+",
	---@param line string
	complete = function(_, line)
		local args = vim.split(line, "%s+")

		if #args == 2 then
			return { "update", "del", "unload", "list" }
		elseif #args >= 3 then
			if utils.lua.table_find({ "update", "del", "unload" }, args[2]) then
				return utils.lua.hashmap(pack.list())
			end
		end

		return {}
	end,
})

create_user_command("Restart", function()
	local cmd = vim.cmd

    cmd("highlight clear")

	if utils.exists(":LspStop") then
		cmd("LspStop")
	end

	pack.unload(utils.lua.hashmap(pack.list()))

	local config = fn.stdpath("config")
	local files = fn.glob(config .. "/**/*.lua", false, true)

	for _, file in ipairs(files) do
		package.loaded[file:gsub("^" .. vim.pesc(config .. "/"), ""):gsub("%.lua$", ""):gsub("/", ".")] = nil
	end

    for _, file in ipairs(files) do
	    cmd("source " .. file)
    end

    if string.match(fn.expand('$MYVIMRC'), '%.lua$') then
        cmd('luafile $MYVIMRC')
    else
        cmd('source $MYVIMRC')
    end

	cmd("doautocmd VimEnter")
end, {})
