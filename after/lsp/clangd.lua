return {
    filetypes = {
        "c",
        "h",
        "cpp",
        "cxx",
        "cc",
        "hpp",
        "hxx",
        "hh",
        "m",
        "mm",
    },
    handlers = {
        ["textDocument/publishDiagnostics"] = function(_, result, ctx)
            if not result then
                return
            end

            local filtered = {}

            for _, diag in ipairs(result.diagnostics) do
                if diag.severity ~= vim.diagnostic.severity.WARN then
                    table.insert(filtered, diag)
                end
            end

            result.diagnostics = filtered
            vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx)
        end,
    },
}
