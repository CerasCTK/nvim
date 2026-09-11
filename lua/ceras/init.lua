local sysname = vim.uv.os_uname().sysname
vim.g.is_windows = (sysname == "Windows_NT")
vim.g.is_linux = (sysname == "Linux")
vim.g.is_mac = (sysname == "Darwin")

if vim.fn.has("nvim-0.12") == 1 then
    require("vim._core.ui2").enable()
    vim.g.ui2_enabled = true
end

require("ceras.option")
require("ceras.keymap")
require("ceras.autocmd")
require("ceras.plugin")
