local registry = packages.plugin.install("mason-org/mason-registry")("mason-registry")
local servers = {
    "lua-language-server",
    "luau-lsp",
}

for _, server in ipairs(servers) do
	local pkg = registry.has_package(server)

	if pkg and not registry.is_installed(server) then
		vim.cmd("MasonInstall " .. server)
	end
end

