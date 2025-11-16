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

	if not utils.isdirectory(path) then
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
        path = path,
	}
end

--- @class Pack.Spec
--- @field src? string URI from which to install and pull updates
--- @field dir string Package Directory
--- @field name string Name of plugin
--- @field version string? Use for install and updates
--- @field path string Path on disk

--- @type table<string, Pack.Spec>
local plugs = {}

--- @type table<string, integer>[]
local event_autocmds = {}

--- @class Pack.AddSpec.Keymap
--- @field mode? string | string[]
--- @field cmd fun() | string
--- @field opts? any

--- @class Pack.AddSpec
--- @field src? string -- Plugin src (url (ex. github.com/kimpure/warp.nvim or https://github.com/kimpure/warp.nvim))
--- @field dir? string -- Plugin dir (local)
--- @field version? string -- Plugin version (branch)
--- @field import? fun() -- Executed when import is done
--- @field boot? fun() | { [1]: string, [string]: any } -- Executed when boot is done
--- @field keymaps? table<string, Pack.AddSpec.Keymap>
--- @field disable? boolean -- Plugin disable
--- @field events string[]? Load plugin event

--- Add packages
--- @param specs Pack.AddSpec[]
function pack.add(specs)
	for i = 1, #specs do
		local spec = specs[i]
		local name = match(spec.src or spec.dir or "unknown", "^.+/(.+)$")
		local import = spec.import
		local boot = spec.boot
		local events = spec.events
		local keymaps = spec.keymaps

		--- @return boolean
		local function import_plugin()
			--- @diagnostic disable-next-line
			local success, message = pcall(vim.cmd, "packadd " .. name)

			if not success then
				vim.notify(message, vim.log.levels.ERROR)

				return false
			end

			if import then
				import()
			end

			return true
		end

		local function boot_plugin()
			if boot then
				if type(boot) == "table" then
					local module_name = boot[1]
					boot[1] = nil

					if utils.lua.mixedtable_len(boot) == 0 then
						boot = nil
					end

					local boot_success, boot_message = pcall(function(module, opt)
						require(module).setup(opt)
					end, module_name, boot)

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
						vim.keymap.set(parm.mode or "n", map, parm.cmd, parm.opts or { noremap = true, silent = true })
					end
				end
			end
		end

		local function load_plugin()
			if events then
				event_autocmds[name] = {}
				for j = 1, #events do
					event_autocmds[name][j] = api.nvim_create_autocmd(events[j], {
						once = true,
						callback = function()
							boot_plugin()
							api.nvim_del_autocmd(event_autocmds[name][j])
						end,
					})
				end
			else
				boot_plugin()
			end
		end

		if spec.dir then
			local dir = fn.expand(spec.dir)

			if utils.isdirectory(dir) then
				if not spec.disable then
					utils.runtime.append(dir)

					plugs[name] = {
						dir = dir,
						name = name,
						version = spec.version,
                        path = spec.dir,
					}

					load_plugin()
				end
			else
				vim.notify("Not found directory: " .. dir, vim.log.levels.WARN)
			end
		elseif spec.src then
			if not spec.disable then
				if import_plugin() then
					plugs[name] = clone_package(spec.src, name, spec.version)

					load_plugin()
				else
					vim.notify("Faild import plugin: " .. name, vim.log.levels.WARN)
				end
			end
		else
			vim.notify("Missing field src or dir", vim.log.levels.WARN)
		end
	end
end

--- Delete packages
--- @param names string[] target package names
function pack.del(names)
    local plugins = pack.get(names)

	for i = 1, #names do
		local name = names[i]

		plugs[name] = nil
        utils.runtime.unload(plugins[i].path)

        if event_autocmds[name] then
			local events = event_autocmds[name]

			for j = 1, #events do
				api.nvim_del_autocmd(event_autocmds[name][j])
				event_autocmds[name] = nil
			end
		end
	end
end

--- Get plugin spec
--- @param names string[] target package names
--- @return Pack.Spec[]
function pack.get(names)
	local result = {}

	for i = 1, #names do
		local name = names[i]

        if plugs[name] then
		    insert(result, plugs[name])
        else
            vim.notify("Not found package: " .. name, vim.log.levels.WARN)
        end
	end

	return result
end

--- Get plugin list
--- @return Pack.Spec[]
function pack.list()
	return utils.lua.hashmap(plugs)
end

--- Update packages
--- @param names string[] target package names
function pack.update(names)
	local plugins = pack.get(names)

    pack.del(names)

    for i = 1, #names do
		pack.add(plugins[i])
	end
end

--- Unload plugins
--- @param names string[] target plugins name
function pack.reload(names)
	local specs = pack.get(names)

    for i = 1, #names do
	    utils.runtime.reload(specs[i].path)
    end
end

return pack
