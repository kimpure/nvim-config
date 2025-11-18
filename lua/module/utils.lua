local api = vim.api
local fn = vim.fn

--- @class Utils
local utils = {}

--- @param feat string The feature name
--- @return boolean
function utils.has(feat)
	return fn.has(feat) == 1
end

--- @param directory string The target directory
--- @return boolean
function utils.isdirectory(directory)
	return fn.isdirectory(directory) ~= 0
end

--- @param feat string The feature name
--- @return boolean
function utils.exists(feat)
	return fn.exists(feat) ~= 0
end

function utils.vimenter()
	vim.cmd("doautocmd VimEnter")
end

local is_windows = utils.has("win32") or utils.has("win64")

--- @class Utils.FileSystem
local fs = {}
fs.path_prefix = is_windows and "\\" or "/"

--- Remove file
--- @param path string target file path
--- @param using_windows? boolean using windows remove option (defulat: false)
function fs.remove(path, using_windows)
	for _, bufnr in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_is_loaded(bufnr) then
			local buf_path = api.nvim_buf_get_name(bufnr)
			if buf_path == path then
				api.nvim_buf_delete(bufnr, { force = true })
			end
		end
	end

	if is_windows and using_windows then
		if utils.isdirectory(path) then
			fn.system({ "cmd", "/c", "rmdir", "/s", "/q", path })
		else
			fn.system({ "cmd", "/c", "del", "/f", "/q", path })
		end
	else
		fn.delete(path, "rf")
	end
end

--- Copy file
--- @param src string
--- @param dst string
function fs.copy(src, dst)
	fn.mkdir(dst, "p")

	if is_windows then
		fn.system({
			"cmd",
			"/C",
			([[xcopy "%s" "%s" /E /I /Y /Q]]):format(src, dst),
		})
	else
		fn.system({ "cp", "-r", src .. "/.", dst })
	end
end

--- @class Utils.FileSystem
utils.fs = fs

--- @class Utils.Lua
local lua = {}

--- @param object table<string, any>
--- @return string[]
function lua.hashmap(object)
	local map = {}

	for k, _ in pairs(object) do
		table.insert(map, k)
	end

	return map
end

--- @param index number
--- @param tab any[]
--- @return any[]
function lua.table_select(index, tab)
	local res = {}

	for i = 0, #tab - index do
		res[i + 1] = tab[index + i]
	end

	return res
end

--- @param tab table<any, any> target table
--- @return number
function lua.mixedtable_len(tab)
	local len = 0

	for _, _ in pairs(tab) do
		len = len + 1
	end

	return len
end

--- @param array table<any, any>
--- @return boolean
function lua.is_array(array)
	for k, _ in pairs(array) do
		if type(k) ~= "number" then
			return false
		end
	end

	return true
end

--- @param value any target value
--- @return string
function lua.tostring(value)
	local format = string.format
	local gsub = string.gsub
	local rep = string.rep

	if type(value) == "table" then
		local result = ""
		for k, v in pairs(value) do
			result = result
				.. format(
					rep(" ", vim.o.tabstop) .. "[%s]: %s",
					type(k) == "table" and (lua.is_array(k) and "array" or "table")
						or (type(k) == "string" and format('"%s"', k) or tostring(k)),
					gsub(lua.tostring(v), "\n([^\n]+)", "\n" .. rep(" ", vim.o.tabstop) .. "%1")
				)
				.. "\n"
		end

		return "{\n" .. result .. "}"
	else
		return tostring(value)
	end
end

--- @param tab any[]
--- @param value any
--- @return number?
function lua.table_find(tab, value)
	for i = 1, #tab do
		if value == tab[i] then
			return i
		end
	end
end

--- @class Utils.Lua
utils.lua = lua

--- @class Utils.Runtime
local runtime = {}

--- Add runtime path
--- @param directory string
function runtime.append(directory)
	vim.opt.runtimepath:append(directory)
	vim.loader.reset()
	vim.loader.enable()
end

--- @class Utils.Runtime
utils.runtime = runtime

--- @class Utils.Packages
local packages = {}

--- Unload directory
function packages.unload(directory)
	directory = fn.expand(directory)

	--- @type string[]
	local files = fn.glob(directory .. "/**/*.lua", false, true)

	for i = 1, #files do
		local module_path = files[i]:sub(#directory + 2)

		local lua_root = module_path:match("^lua/") or module_path:match("^lua\\")

		if lua_root then
			module_path = module_path:sub(5)

			local filename = module_path:match("([^/\\]+)$")
			local mod

			if filename == "init.lua" then
				mod = module_path:sub(1, -10):gsub("/", "."):gsub("\\", ".")
			else
				mod = module_path:sub(1, -5):gsub("/", "."):gsub("\\", ".")
			end

			package.loaded[mod] = nil
		end
	end
end

--- @class Utils.Packages
utils.packages = packages

return utils
