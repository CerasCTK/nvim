local compat = require("ceras.environment.compat")

local M = {}

M.sysname = compat.uv.os_uname().sysname

M.is_windows = M.sysname == "Windows_NT"
M.is_linux = M.sysname == "Linux"
M.is_mac = M.sysname == "Darwin"

return M
