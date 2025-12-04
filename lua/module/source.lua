--- @param path string source path
return function(path)
    if path:sub(-4, -4) ~= ".vim" then
        path = path .. ".vim"
    end
    path = path:gsub("\\.", "/")

    vim.cmd("source " .. vim.fs.joinpath(vim.fs.joinpath(vim.fn.stdpath("config"), "vim"), path))
end
