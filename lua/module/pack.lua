--- @class Pack
local pack = {}

local api = vim.api
local fn = vim.fn

local data_path = fn.stdpath("data")
local opt_path = data_path .. "/site/pack/plugins/opt/"

local sub = string.sub
local match = string.match
local insert = table.insert

--- @param src string package url
--- @param name string? package name
--- @param version string? package version
--- @return Pack.Spec
local function clone_package(src, name, version)
	src = sub(src, 6) == "https:" and src or "https://" .. src
	name = name or match(src, "^.+/(.+)$")
	local path = opt_path .. name

	if utils.isdirectory(path) then
		local cmd = { "git", "clone", "--depth=1" }

		if version then
			insert(cmd, "--branch")
			insert(cmd, version)
		end

		insert(cmd, src)
		insert(cmd, path)

		local sys = fn.system(cmd)

		if vim.v.shell_error ~= 0 then
			vim.notify("Faild to clone " .. name, vim.log.levels.ERROR)
			vim.notify("Error: " .. sys, vim.log.levels.ERROR)
			fn.getchar()
		end
	end

	return {
		src = src,
        dir = opt_path .. name,
		name = name,
		version = version,
	}
end

--- @class Pack.Spec
--- @field src? string URI from which to install and pull updates
--- @field dir string Package Directory
--- @field name string Name of plugin
--- @field version string? Use for install and updates

--- @type table<string, Pack.Spec>
local plugs = {}

--- @type table<string, integer>
local not_load_plugins = {}

--- @class Pack.AddSpec.Keymap
--- @field mode? string | string[]
--- @field cmd fun() | string
--- @field opts? any

--- @class Pack.AddSpec
--- @field src? string
--- @field dir? string
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
		local name = match(spec.src, "^.+/(.+)$")
		local boot = spec.boot
		local event = spec.event
		local keymaps = spec.keymaps

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

		if spec.dir then
			local dir = fn.expand(spec.dir)

            if utils.isdirectory(dir) then
				vim.opt.runtimepath:append(dir)

				if not spec.disable then
					plugs[name] = {
                        src = dir,
                        dir = dir,
                        name = name,
                        version = spec.version,
                    }

                    if event then
						not_load_plugins[name] = api.nvim_create_autocmd(event, {
							once = true,
							callback = function()
								boot_plugin()
								api.nvim_del_autocmd(not_load_plugins[name])
							end,
						})
					else
						boot_plugin()
					end
				end
			else
				vim.notify("Not found directory: " .. dir, vim.log.levels.WARN)
			end
		elseif spec.src then
			if not spec.disable then
                plugs[name] = clone_package(spec.src, name, spec.version)

				if event then
					not_load_plugins[name] = api.nvim_create_autocmd(event, {
						once = true,
						callback = function()
							boot_plugin()
							api.nvim_del_autocmd(not_load_plugins[name])
						end,
					})
				else
					boot_plugin()
				end
			end
		else
			vim.notify("Missing field src or dir", vim.log.levels.ERROR)
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
		fn.delete(path, "rf")
		if not_load_plugins[name] then
			api.nvim_del_autocmd(not_load_plugins[name])
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

--- Get plugin list
--- @return table<string, Pack.Spec>
function pack.list()
	return plugs
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
            vim.notify("Faild to update " .. name .. ", package not found", vim.log.levels.WARN)
		end
	end
end

--- Unload plugins
--- @param names string[] target plugins name
function pack.unload(names)
    for i=1, #names do
        local name = names[i]

        if plugs[name] then
            package.loaded[name] = nil
        else
            vim.notify("Faild to unload" .. name .. ", package not found", vim.log.levels.WARN)
        end
    end
end

return pack
