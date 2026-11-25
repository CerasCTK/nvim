local M = {}

local default_mode = "auto"
local supported_modes = { "auto", "git", "file", "manual" }
local mode_descriptions = {
    auto = "Nearest project root",
    git = "Git repository root",
    file = "Current file directory",
    manual = "Disable automatic directory switching",
}

M.find_project_root = function(bufnr)
    local simple_patterns = { ".git", "package.json" }
    local complex_patterns = { "build/compile_commands.json" }

    local absolute_paths = { vim.fn.stdpath("config") }

    local parent_paths = { "~/.config" }
    if vim.g.is_windows then
        table.insert(parent_paths, "~/Workspace")
    else
        table.insert(parent_paths, "~/workspace")
    end

    return vim.fs.root(bufnr, function(name, path)
        return vim.iter(simple_patterns):any(function(pattern)
            return pattern == name
        end) or
        vim.iter(complex_patterns):any(function(pattern_path)
            return vim.uv.fs_stat(vim.fs.joinpath(path, vim.fs.normalize(pattern_path)))
        end) or
        vim.iter(absolute_paths):any(function(dir_path)
            return vim.fs.normalize(dir_path) == path
        end) or
        vim.iter(parent_paths):any(function(parent_path)
            return vim.fs.normalize(parent_path) == vim.fs.dirname(path)
        end)
    end)
end

M.find_git_root = function(bufnr)
    return vim.fs.root(bufnr, ".git")
end

M.get_file_directory = function(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)

    if filename == "" then return nil end

    return vim.fs.dirname(filename)
end

M.get_mode = function()
    return vim.w.workspace_mode or default_mode
end

M.update = function(bufnr)
    if vim.bo[bufnr].buftype ~= "" then
        return nil, "Cannot resolve workspace for special buffers"
    end

    if vim.api.nvim_buf_get_name(bufnr) == "" then
        return nil, "Current buffer has no file name"
    end

    local mode = M.get_mode()

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
    if not vim.tbl_contains(supported_modes, mode) then
        vim.notify("Invalid workspace mode: " .. tostring(mode), vim.log.levels.WARN, { title = "Workspace" })
        return
    end

    vim.w.workspace_mode = mode

    if mode == "manual" then
        vim.notify(
            "Workspace mode: manual\nAutomatic directory switching disabled",
            vim.log.levels.INFO,
            { title = "Workspace" }
        )

        return
    end

    local root, err = M.update(vim.api.nvim_get_current_buf())

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
            "Workspace mode: " .. mode .. "\nDirectory: " .. vim.fn.fnamemodify(root, ":~"),
            vim.log.levels.INFO,
            { title = "Workspace" }
        )
    end
end

M.select_mode = function()
    local winid = vim.api.nvim_get_current_win()

    vim.ui.select(
        supported_modes,
        {
            prompt = "Select workspace mode (current: " .. M.get_mode() .. ")",
            format_item = function(mode)
                return mode .. " - " .. mode_descriptions[mode]
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
