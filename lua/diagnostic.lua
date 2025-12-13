local diagnostic = vim.diagnostic
local api = vim.api

local orig = vim.diagnostic.handlers.virtual_lines

diagnostic.handlers.virtual_lines = {
    show = function(ns, bufnr, diagnostics, opts)
        local cursor = api.nvim_win_get_cursor(0)[1] - 1

        local filtered = {}
        for _, d in ipairs(diagnostics) do
            if d.lnum == cursor then
                table.insert(filtered, d)
            end
        end

        orig.show(ns, bufnr, filtered, opts)
    end,

    hide = orig.hide,
}

diagnostic.config({
    virtual_text = true,
    virtual_lines = { only_current_line = true },
    underline = true,
    severity_sort = true,
    severity = { min = diagnostic.severity.WARN },
    update_in_insert = true,
    signs = {
        text = {
            [diagnostic.severity.ERROR] = "E",
            [diagnostic.severity.WARN] = "W",
            [diagnostic.severity.INFO] = "I",
            [diagnostic.severity.HINT] = "H",
        },
    },
    float = {
        source = true,
        header = "Diagnostics:",
        prefix = " ",
        border = "single",
        max_height = 10,
        max_width = 130,
        close_events = { "CursorMoved", "BufLeave", "WinLeave" },
    },
})

api.nvim_create_autocmd("CursorHold", {
    pattern = "*",
    callback = function()
        if #vim.diagnostic.get(0) == 0 then
            return
        end

        if not vim.b.diagnostics_pos then
            vim.b.diagnostics_pos = { nil, nil }
        end

        local cursor_pos = api.nvim_win_get_cursor(0)

        if not vim.deep_equal(cursor_pos, vim.b.diagnostics_pos) then
            diagnostic.open_float(nil, {
                border = "none",
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                scope = "cursor",
            })
        end

        vim.b.diagnostics_pos = cursor_pos
    end,
})

api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    callback = function()
        vim.diagnostic.show()
    end,
})
