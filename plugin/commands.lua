local api = vim.api
local fn = vim.fn
local create_user_command = api.nvim_create_user_command

create_user_command("Pack", function(opts)
	local fargs = opts.fargs
	local command = fargs[1]
	local targets = utils.lua.table_select(2, fargs)

	if command == "update" then
		pack.update(targets)
	elseif command == "del" then
		pack.del(targets)
	elseif command == "reload" then
		pack.reload(targets or pack.list())
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
			return { "update", "del", "reload", "list" }
		elseif #args >= 3 then
			if utils.lua.table_find({ "update", "del", "reload" }, args[2]) then
				return pack.list()
			end
		end

		return {}
	end,
})

