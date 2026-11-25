local M = {}

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

return M
