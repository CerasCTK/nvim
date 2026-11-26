local compat = require("ceras.environment.compat")

local sysname = compat.uv.os_uname().sysname
vim.g.is_windows = (sysname == "Windows_NT")
vim.g.is_linux = (sysname == "Linux")
vim.g.is_mac = (sysname == "Darwin")

if compat.has("0.12") then
    local ok, ui2 = pcall(require, "vim._core.ui2")

    if ok then
        vim.g.ui2_enabled = pcall(ui2.enable)
    end
end

require("ceras.option")
require("ceras.keymap")
require("ceras.autocmd")
require("ceras.plugin")
