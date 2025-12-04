local ns = vim.api.nvim_create_namespace("VisualSpaceHighlight")

local function clear()
    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
end

local function show_spaces_in_visual()
    clear()

    local mode = vim.fn.mode()
    if mode ~= "v" and mode ~= "V" and mode ~= "\022" then
        return
    end

    local pos1 = vim.fn.getpos("v")
    local pos2 = vim.fn.getpos(".")
    local line1, col1 = pos1[2] - 1, pos1[3] - 1
    local line2, col2 = pos2[2] - 1, pos2[3] - 1

    if line2 < line1 or (line2 == line1 and col2 < col1) then
        line1, line2 = line2, line1
        col1, col2 = col2, col1
    end

    local lines = vim.api.nvim_buf_get_lines(0, line1, line2 + 1, false)

    for i, line in ipairs(lines) do
        local lnum = line1 + i - 1

        local leading_end = line:match("^%s*()") - 1
        local start_col = 0
        local end_col = leading_end

        for c = start_col, math.min(end_col, #line - 1) do
            if line:sub(c + 1, c + 1) == " " then
                vim.api.nvim_buf_set_extmark(0, ns, lnum, c, {
                    virt_text = { { "·", "Visual" } },
                    virt_text_pos = "overlay",
                })
            end
        end
    end
end

vim.api.nvim_create_autocmd({ "ModeChanged", "CursorMoved", "CursorMovedI" }, {
    pattern = "*",
    callback = function()
        if vim.fn.mode():match("[vV\022]") then
            show_spaces_in_visual()
        else
            clear()
        end
    end,
})
