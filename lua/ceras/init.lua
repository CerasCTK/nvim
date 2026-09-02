if vim.fn.has("nvim-0.12") == 1 then
    require("vim._core.ui2").enable()
    vim.g.ui2_enabled = true
end

require("ceras.option")
require("ceras.keymap")
require("ceras.autocmd")
require("ceras.plugin")
