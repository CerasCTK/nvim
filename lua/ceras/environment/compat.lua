local M = {}

M.version = vim.version()

M.uv = vim.uv or vim.loop
M.highlight = vim.hl or vim.highlight

M.has = function(version)
    return vim.fn.has("nvim-" .. version) == 1
end

return M
