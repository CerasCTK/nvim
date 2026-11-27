local compat = require("ceras.environment.compat")
local platform = require("ceras.environment.platform")
local config = require("ceras.config")

local M = {}

local supported_modes = { "auto", "git", "file", "manual" }
local selectable_modes = vim.list_extend({ "inherit" }, supported_modes)

local mode_descriptions = {
    inherit = "Follow project preference or default mode",
    auto = "Nearest project root",
    git = "Git repository root",
    file = "Current file directory",
    manual = "Disable automatic directory switching",
}

local find_root = function(bufnr, matches)
    local filename = vim.api.nvim_buf_get_name(bufnr)

    if filename == "" then return nil end

    filename = vim.fs.normalize(filename, { expand_env = false })

    for path in vim.fs.parents(filename) do
        if vim.fn.isdirectory(path) == 1 and matches(path) then
            return path
        end
    end

    return nil
end

local has_marker = function(path, marker)
    local marker_path = path:gsub("/$", "") .. "/" .. marker

    return compat.uv.fs_stat(marker_path) ~= nil
end

M.setup_editorconfig = function()
    require("editorconfig").properties.nvim_workspace_mode = function(_, value)
        local is_valid_mode = vim.tbl_contains(supported_modes, value)

        if not is_valid_mode then
            error("Invalid workspace mode: " .. value, 0)
        end
    end
end

M.find_project_root = function(bufnr)
    local patterns = {
        ".git",
        "package.json",
        "build/compile_commands.json",
    }

    local config_path = vim.fs.normalize(vim.fn.stdpath("config"))

    local parent_paths = { "~/.config" }
    if platform.is_windows then
        table.insert(parent_paths, "~/Workspace")
    else
        table.insert(parent_paths, "~/workspace")
    end

    for index, path in ipairs(parent_paths) do
        parent_paths[index] = vim.fs.normalize(path)
    end

    return find_root(bufnr, function(path)
        for _, pattern in ipairs(patterns) do
            if has_marker(path, pattern) then
                return true
            end
        end

        if path == config_path then
            return true
        end

        return vim.tbl_contains(parent_paths, vim.fs.dirname(path))
    end)
end

M.find_git_root = function(bufnr)
    return find_root(bufnr, function(path)
        return has_marker(path, ".git")
    end)
end

M.get_file_directory = function(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)

    if filename == "" then return nil end

    return vim.fs.dirname(filename)
end

M.get_project_mode = function(bufnr)
    local editorconfig = vim.b[bufnr].editorconfig

    if type(editorconfig) ~= "table" then return nil end

    local mode = editorconfig.nvim_workspace_mode

    if vim.tbl_contains(supported_modes, mode) then
        return mode
    end

    return nil
end

M.get_mode = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    return vim.w.workspace_mode
        or M.get_project_mode(bufnr)
        or config.workspace.default_mode
end

M.update = function(bufnr)
    if vim.bo[bufnr].buftype ~= "" then
        return nil, "Cannot resolve workspace for special buffers"
    end

    if vim.api.nvim_buf_get_name(bufnr) == "" then
        return nil, "Current buffer has no file name"
    end

    local mode = M.get_mode(bufnr)

    if mode == "manual" then return end

    local root

    if mode == "auto" then
        root = M.find_project_root(bufnr) or M.get_file_directory(bufnr)
    elseif mode == "git" then
        root = M.find_git_root(bufnr)
    elseif mode == "file" then
        root = M.get_file_directory(bufnr)
    end

    if not root then
        return nil, mode == "git" and "No Git repository found" or "Cannot resolve workspace root"
    end

    if vim.fn.isdirectory(root) ~= 1 then
        return nil, "Workspace directory does not exist"
    end

    vim.cmd.lcd(root)

    return root
end

M.set_mode = function(mode)
    if not vim.tbl_contains(selectable_modes, mode) then
        vim.notify("Invalid workspace mode: " .. tostring(mode), vim.log.levels.WARN, { title = "Workspace" })
        return
    end

    if mode == "inherit" then
        vim.w.workspace_mode = nil
    else
        vim.w.workspace_mode = mode
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local effective_mode = M.get_mode(bufnr)

    if effective_mode == "manual" then
        vim.notify(
            "Workspace mode: manual\nAutomatic directory switching disabled",
            vim.log.levels.INFO,
            { title = "Workspace" }
        )

        return
    end

    local root, err = M.update(bufnr)

    if err then
        vim.notify(
            err .. "\nWorking directory unchanged",
            vim.log.levels.WARN,
            { title = "Workspace" }
        )

        return
    end

    if root then
        vim.notify(
            "Workspace mode: " .. effective_mode .. "\nDirectory: " .. vim.fn.fnamemodify(root, ":~"),
            vim.log.levels.INFO,
            { title = "Workspace" }
        )
    end
end

M.select_mode = function()
    local winid = vim.api.nvim_get_current_win()

    local current_mode = M.get_mode()
    local selected_mode = vim.w.workspace_mode or "inherit"

    vim.ui.select(
        selectable_modes,
        {
            prompt = "Select workspace mode (current: " .. current_mode .. ")",
            format_item = function(mode)
                local label = mode .. " - " .. mode_descriptions[mode]

                if mode == selected_mode then
                    label = label .. " (selected)"
                end

                return label
            end,
        },
        function(choice)
            if not choice then return end
            if not vim.api.nvim_win_is_valid(winid) then return end

            vim.api.nvim_win_call(winid, function()
                M.set_mode(choice)
            end)
        end
    )
end

return M
