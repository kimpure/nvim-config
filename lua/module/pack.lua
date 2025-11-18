--- @class Pack
local pack = {}

local api = vim.api
local fn = vim.fn

local data_path = fn.stdpath("data")
local opt_path = data_path .. "/site/pack/plugins/opt/"

local sub = string.sub
local match = string.match

local insert = table.insert

--- @param spec Pack.Spec
--- @return Pack.Spec.Src
local function clone_package(spec)
	local src = spec.src
	local name = spec.name
	local version = spec.version

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

	return vim.tbl_extend("force", spec, {
		src = src,
		name = name,
		path = path,
	})
end

--- @alias Pack.Plugin Pack.Spec.Src | Pack.Plugin.Dir

--- @class Pack.Plugin.Src: Pack.Spec.Src
--- @field path string
--- @field name string

--- @class Pack.Plugin.Dir: Pack.Spec.Dir
--- @field path string
--- @field name string

--- @alias Pack.Spec Pack.Spec.Src | Pack.Spec.Dir

--- @class Pack.Spec.Base
--- @field name? string
--- @field version? string -- Plugin version (branch)
--- @field import? fun() -- Executed when import is done
--- @field boot? Pack.Spec.Boot -- Executed when boot is done
--- @field keymaps? table<string, Pack.Spec.Keymap>
--- @field disable? boolean -- Plugin disable
--- @field events string[]? -- Load plugin events

--- @class Pack.Spec.Src: Pack.Spec.Base
--- @field src string -- Plugin src (url (ex. github.com/kimpure/warp.nvim or https://github.com/kimpure/warp.nvim))

--- @class Pack.Spec.Dir: Pack.Spec.Base
--- @field dir string -- Plugin dir (local)

--- @alias Pack.Spec.Boot Pack.Spec.Boot.Config | Pack.Spec.Boot.CallBack

--- @class Pack.Spec.Boot.Config
--- @field [1] string -- Plugin name
--- @field [string] any -- Plugin options

--- @alias Pack.Spec.Boot.CallBack fun()

--- @class Pack.Spec.Keymap
--- @field mode? string | string[]
--- @field cmd fun() | string
--- @field opts? any

--- @type table<string, Pack.Plugin>
vim.plugins = {}
local plugins = vim.plugins

--- @type table<string, integer>[]
local event_autocmds = {}

--- Add plugins
--- @param specs Pack.Spec[]
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

					local success, message = pcall(function(module, opt)
						require(module).setup(opt)
					end, module_name, boot)

					if not success then
						--- @diagnostic disable-next-line
						vim.notify(message, vim.log.levels.ERROR)
					end

					boot[1] = module_name
				else
					--- @diagnostic disable-next-line
					local success, message = pcall(boot)

					if not success then
						vim.notify(message, vim.log.levels.ERROR)
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

					plugins[name] = vim.tbl_extend("force", spec, {
						path = dir,
						name = name,
					})

					load_plugin()
				end
			else
				vim.notify("Not found directory: " .. dir, vim.log.levels.WARN)
			end
		elseif spec.src then
			if not spec.disable then
				if import_plugin() then
					plugins[name] = clone_package(spec)

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

--- Delete plugins
--- @param names string[] target package names
function pack.del(names)
	for i = 1, #names do
		local name = names[i]

		utils.packages.unload(plugins[name].path)

		plugins[name] = nil

		if event_autocmds[name] then
			local events = event_autocmds[name]

			for j = 1, #events do
				api.nvim_del_autocmd(event_autocmds[name][j])
				event_autocmds[name] = nil
			end
		end
	end
end

--- Get plugins spec
--- @param names string[] target package names
--- @return Pack.Plugin[]
function pack.get(names)
	local result = {}

	for i = 1, #names do
		local name = names[i]

		if plugins[name] then
			insert(result, plugins[name])
		else
			vim.notify("Not found package: " .. name, vim.log.levels.WARN)
		end
	end

	return result
end

--- Get plugin list
--- @return Pack.Plugin[]
function pack.list()
	return utils.lua.hashmap(plugins)
end

--- Update plugins
--- @param names string[] target plugin names
function pack.update(names)
	pack.del(names)
	pack.add(pack.get(names))
end

--- Reload plugins
--- @param names string[] target plugin name
function pack.reload(names)
	local specs = pack.get(names)

	for i = 1, #names do
		utils.packages.unload(specs[i].path)
	end

	pack.add(specs)

	utils.vimenter()
end

return pack
