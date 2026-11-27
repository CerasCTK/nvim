local compat = require("ceras.environment.compat")
local config = require("ceras.config")

if config.experimental.ui2 and compat.has("0.12") then
    local ok, ui2 = pcall(require, "vim._core.ui2")

    if ok then
        vim.g.ui2_enabled = pcall(ui2.enable)
    end
end

require("ceras.option")
require("ceras.keymap")
require("ceras.autocmd")
require("ceras.plugin")
