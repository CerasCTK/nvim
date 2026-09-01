if vim.fn.has("nvim-0.12") == 1 then
	vim.cmd("packadd nvim.difftool")
	vim.cmd("packadd nvim.undotree")
end

vim.cmd("syntax off")

vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_shada_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_remote_plugins = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.editorconfig = false
