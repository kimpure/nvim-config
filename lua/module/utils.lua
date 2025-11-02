local fn = vim.fn

--- @class Utils
local utils = {}

--- @param feat string the feature name, like 'unix'
--- @return boolean
function utils.has(feat)
	return fn.has(feat) == 1
end

--- @param object table<string, any>
--- @return string[]
function utils.hashmap(object)
    local map = {}

    for k, _ in pairs(object) do
        table.insert(map, k)
    end

    return map
end

--- @param index number
--- @param tab any[]
--- @return any[]
function utils.select_table(index, tab)
    local res = {}

    for i=0, #tab - index do
        res[i + 1] = tab[index + i]
    end

    return res
end

local is_windows = utils.has("win32") or utils.has("win64")

--- @class Utils.FileSystem
local fs = {}
fs.path_prefix = is_windows and "\\" or "/"

--- Remove directory
--- @param path string target file path
--- @param using_windows? boolean using windows remove option (defulat: false)
function fs.remove_file(path, using_windows)
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

return utils
