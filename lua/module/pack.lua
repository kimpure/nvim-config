--- @class Pack
local pack = {}

local data_path = vim.fn.stdpath("data")
local opt_path = data_path .. "/site/pack/plugins/opt/"

local sub = string.sub
local match = string.match
local insert = table.insert

--- @param src string package url
--- @param name string? package name
--- @param version string? package version
--- @return Pack.Spec
local function get_package(src, name, version)
src = sub(src, 6) == "https:" and src or "https://" .. src
name = name or match(src, "^.+/(.+)$")
local path = opt_path .. name

if vim.fn.isdirectory(path) < 1 then
    local cmd = { "git", "clone", "--depth=1" }

    if version then
        insert(cmd, "--branch")
        insert(cmd, version)
    end

    insert(cmd, src)
    insert(cmd, path)

    local sys = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
        vim.notify("Faild to clone " .. name, vim.log.levels.ERROR)
        vim.notify("Error: " .. sys, vim.log.levels.ERROR)
        vim.fn.getchar()
    end
end

return {
    src = src,
    name = name,
    version = version,
}
end

--- @class Pack.Spec
--- @field src string URI from which to install and pull updates
--- @field name string Name of plugin
--- @field version string? Use for install and updates
--- @field load boolean? Load plugin status

--- @type table<string, Pack.Spec>
local plugs = {}

--- @type table<string, integer>
local not_load_plugins = {}

--- @class Pack.AddSpec.Keymap
--- @field mode? string | string[]
--- @field cmd fun() | string
--- @field opts? any

--- @class Pack.AddSpec
--- @field src string
--- @field version? string
--- @field boot? fun() | { [1]: string, [string]: any }
--- @field keymaps? table<string, Pack.AddSpec.Keymap>
--- @field disable? boolean
--- @field event string? Load plugin event

--- Add packages
--- @param specs Pack.AddSpec[]
function pack.add(specs)
	for i = 1, #specs do
		local spec = specs[i]

		if not spec.disable then
			local name = match(spec.src, "^.+/(.+)$")
			local boot = spec.boot
			local event = spec.event
			local keymaps = spec.keymaps

			plugs[name] = get_package(spec.src, name, spec.version)

            local function boot_plugin()
                --- @diagnostic disable-next-line
                local success, message = pcall(vim.cmd, "packadd " .. name)

                if success then
                    if boot then
                        if type(boot) == "table" then
                            local boot_name = boot[1]
                            boot[1] = nil

                            if utils.lua.mixedtable_len(boot) == 0 then
                                boot = nil
                            end

                            local boot_success, boot_message = pcall(function(n, o)
                                require(n).setup(o)
                            end, boot_name, boot)

                            if not boot_success then
                                --- @diagnostic disable-next-line
                                vim.notify(boot_message, vim.log.levels.ERROR)
                            end
                        else
                            local boot_success, boot_message = pcall(boot)

                            if not boot_success then
                                vim.notify(boot_message, vim.log.levels.ERROR)
                            end
                        end

                        if keymaps then
                            for map, parm in pairs(keymaps) do
                                vim.keymap.set(
                                    parm.mode or "n",
                                    map,
                                    parm.cmd,
                                    parm.opts or { noremap = true, silent = true }
                                )
                            end
                        end
                    end
                else
                    vim.notify(message, vim.log.levels.ERROR)
                end
            end

			if event then
				not_load_plugins[name] = vim.api.nvim_create_autocmd(event, {
					once = true,
					callback = function()
                        boot_plugin()
						vim.api.nvim_del_autocmd(not_load_plugins[name])
					end,
				})
			else
                boot_plugin()
			end
		end
	end
end

--- Delete packages
--- @param names string[] target package names
function pack.del(names)
	for i = 1, #names do
		local name = names[i]
		local path = opt_path .. name
		plugs[name] = nil
		package.loaded[name] = nil
		vim.fn.delete(path, "rf")
		if not_load_plugins[name] then
			vim.api.nvim_del_autocmd(not_load_plugins[name])
			not_load_plugins[name] = nil
		end
	end
end

--- @class Pack.PluginInfo
--- @field spec Pack.Spec plugin pack
--- @field path string path on disk

--- Get packages pack
--- @param names string[] target package names
--- @return table<string, Pack.PluginInfo>
function pack.get(names)
	local result = {}

	for i = 1, #names do
		local name = names[i]

		if plugs[name] then
			result[name] = {
				spec = plugs[name],
				path = opt_path .. name,
			}
		end
	end

	return result
end

--- Update packages
--- @param names string[] target package names
function pack.update(names)
	for i = 1, #names do
		local name = names[i]

		if plugs[name] then
			local plugin = pack.get({ name })

			pack.del({ name })
			pack.add(plugin)
		else
			vim.api.nvim_echo({
				{ "Failed to update " .. name },
				{ " | package not found" },
			}, true, {})
		end
	end
end

vim.api.nvim_create_user_command("Pack", function(opts)
	local fargs = opts.fargs
	local command = fargs[1]
	local target = utils.lua.select_table(2, fargs)

	if command == "update" then
		pack.update(target)
	elseif command == "del" then
		pack.del(target)
	elseif command == "add" then
		pack.add({ src = target })
	else
		vim.notify("Unknown argument: " .. command, vim.log.levels.WARN)
	end
end, {
	nargs = "+",
	---@param line string
	complete = function(_, line)
		local args = vim.split(line, "%s+")

		if #args == 2 then
			return { "update", "add", "del", "open" }
		elseif #args >= 3 then
			if args[2] == "update" or args[2] == "del" then
				return utils.lua.hashmap(plugs)
			end
		end

		return {}
	end,
})

return pack
