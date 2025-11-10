local api = vim.api
local fn = vim.fn

--- @class Utils
local utils = {}

--- @param feat string the feature name, like 'unix'
--- @return boolean
function utils.has(feat)
	return fn.has(feat) == 1
end

--- @param path string the target path
--- @return boolean
function utils.isdirectory(path)
    return fn.isdirectory(path) < 1
end

--- @param feat string
--- @return boolean
function utils.exists(feat)
    return fn.exists(feat) ~= 0
end

local is_windows = utils.has("win32") or utils.has("win64")

--- @class Utils.FileSystem
local fs = {}
fs.path_prefix = is_windows and "\\" or "/"

--- Remove directory
--- @param path string target file path
--- @param using_windows? boolean using windows remove option (defulat: false)
function fs.remove_file(path, using_windows)
	for _, bufnr in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_is_loaded(bufnr) then
			local buf_path = api.nvim_buf_get_name(bufnr)
			if buf_path == path then
				api.nvim_buf_delete(bufnr, { force = true })
			end
		end
	end

	if is_windows and using_windows then
		if fn.isdirectory(path) == 1 then
			fn.system({ "cmd", "/c", "rmdir", "/s", "/q", path })
		else
			fn.system({ "cmd", "/c", "del", "/f", "/q", path })
		end
	else
		fn.delete(path, "rf")
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


--- inspect
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
    for i=1, #tab do
        if value == tab[i] then
            return i
        end
    end
end

--- @class Utils.Lua
utils.lua = lua

--- @class Utils.Lsp
local lsp = {}

--- @return lsp.ClientCapabilities
function lsp.create_capabilities()
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

	return capabilities
end

--- @class Utils.Lsp
utils.lsp = lsp

return utils
