local schemas = {
    {
        name = "default.project.json",
        description = "JSON schema for Rojo project files",
        fileMatch = { "*.project.json" },
        url = "https://raw.githubusercontent.com/rojo-rbx/vscode-rojo/master/schemas/project.template.schema.json",
    },
    {
        name = ".luaurc",
        description = "JSON schema for .luaurc files",
        fileMatch = { ".luaurc" },
        url = "https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/editors/code/schemas/luaurc.json",
    },
}

return {
    settings = {
        json = {
            format = {
                enable = true,
            },
            schemas = schemas,
            validate = { enable = true },
        },
    },
}
