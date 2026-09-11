vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
    desc = "Highlight selected text when yanking",
    callback = function()
        vim.hl.on_yank()
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("AutoCreateDir", { clear = true }),
    desc = "Create missing directories when save file",
    callback = function(args)
        local path = args.match
        local has_uri_scheme = path:match("^%w%w+:[\\/][\\/]")

        if has_uri_scheme then return end

        local absolute_path = vim.uv.fs_realpath(path) or path
        local parent_directory = vim.fn.fnamemodify(absolute_path, ":p:h")

        vim.fn.mkdir(parent_directory, "p")
    end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("RestoreLastLocation", { clear = true }),
    desc = "Auto restore last cursor position after buffer displayed in a window",
    callback = function(args)
        if vim.o.diff then return end

        local excluded_filetypes = { "gitcommit" }

        local bufnr = args.buf
        local filetype = vim.bo[bufnr].filetype

        local is_excluded = vim.tbl_contains(excluded_filetypes, filetype)
        local is_restored_last_location = vim.b[bufnr].last_loc_restored

        if is_excluded or is_restored_last_location then
            return
        end

        local last_position = vim.api.nvim_buf_get_mark(bufnr, "\"")

        local total_lines = vim.api.nvim_buf_line_count(bufnr)

        local row = last_position[1]
        local is_valid_position = row > 0 and row <= total_lines

        if is_valid_position then
            local is_ok, _ = pcall(vim.api.nvim_win_set_cursor, 0, last_position)

            if is_ok then
                vim.b[bufnr].last_loc_restored = true
            end
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("FastCloseWindow", { clear = true }),
    desc = "Close special windows using 'q' key",
    pattern = { "help", "man", "qf", "nvim-undotree" },
    callback = function(args)
        local bufnr = args.buf

        vim.bo[bufnr].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr, desc = "Close special window" })
    end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    group = vim.api.nvim_create_augroup("AutoRead", { clear = true }),
    desc = "Automatically reload buffers when file changes are detected on disk",
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("TrimWhitespace", { clear = true }),
    desc = "Automatically trim trailing whitespaces before saving the file",
    pattern = "*",
    callback = function()
        local save_cursor_pos = vim.fn.getpos(".")

        vim.cmd([[%s/\s\+$//e]])

        vim.fn.setpos(".", save_cursor_pos)
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("BetterDocument", { clear = true }),
    desc = "Configure text layout and enable spellcheck for prose and documentation files",
    pattern = { "markdown", "text", "plaintex", "gitcommit" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("RestoreYankCursor", { clear = true }),
    desc = "Restore the cursor position back to its pre-yank location immediately after copy text",
    callback = function()
        if vim.v.event.operator == "y" and vim.b.cursor_pre_yank then
            vim.api.nvim_win_set_cursor(0, vim.b.cursor_pre_yank)
            vim.b.cursor_pre_yank = nil
        end
    end,
})

local auto_cursorline_group = vim.api.nvim_create_augroup("AutoCursorline", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    group = auto_cursorline_group,
    desc = "Automatically enable cursorline when entering a window or leaving Insert mode",
    callback = function()
        if vim.w.auto_cursorline then
            vim.wo.cursorline = true
            vim.w.auto_cursorline = false
        end
    end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
    group = auto_cursorline_group,
    desc = "Automatically disable cursorline when leaving a window or entering Insert mode",
    callback = function()
        if vim.wo.cursorline then
            vim.w.auto_cursorline = true
            vim.wo.cursorline = false
        end
    end,
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = vim.api.nvim_create_augroup("ScrollEndOfFile", { clear = true }),
    desc = "Fix scrolloff when you are at the end of file",
    callback = function()
        local is_floating_window = vim.api.nvim_win_get_config(0).relative ~= ""
        local is_non_file_buffer = vim.bo.buftype ~= ""

        if is_floating_window or is_non_file_buffer then return end

        local current_row = vim.api.nvim_win_get_cursor(0)[1]
        local total_lines = vim.api.nvim_buf_line_count(0)
        local win_height = vim.fn.winheight(0)

        if total_lines <= win_height then return end

        local scrolloff = math.min(vim.o.scrolloff, math.floor(win_height / 2))

        if total_lines - current_row <= scrolloff then
            local visual_distance_to_eof = win_height - vim.fn.winline()

            if visual_distance_to_eof < scrolloff then
                local win_view = vim.fn.winsaveview()

                vim.fn.winrestview({ topline = win_view.topline + scrolloff - visual_distance_to_eof })
            end
        end
    end,
})

local term_bg_group = vim.api.nvim_create_augroup("TerminalBackgroundSync", { clear = true })
vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
    group = term_bg_group,
    desc = "Synchronize terminal emulator padding background with Neovim colorscheme",
    callback = function()
        local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })

        if normal_hl and normal_hl.bg then
            -- Send OSC 11 escape sequence to dynamically alter the terminal's window background color
            io.write(string.format("\027]11;#%06x\027\\", normal_hl.bg))
        end
    end,
})

vim.api.nvim_create_autocmd("UILeave", {
    group = term_bg_group,
    desc = "Reset terminal emulator window background to its default theme configuration upon exit",
    callback = function()
        -- Send OSC 111 escape sequence to restore original terminal background settings
        io.write("\027]111\027\\")
    end,
})

local auto_root_group = vim.api.nvim_create_augroup("AutoProjectRoot", { clear = true })
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = auto_root_group,
    desc = "Set temporary local directory using vim.fs.root upon opening a file",
    callback = function(args)
        if vim.bo.buftype ~= "" then return end

        local simple_patterns = { ".git", "package.json" }
        local complex_patterns = { "build/compile_commands.json" }

        local absolute_paths = { vim.fn.stdpath("config") }

        local parent_paths = { "~/.config" }
        if vim.g.is_windows then
            table.insert(parent_paths, "~/Workspace")
        else
            table.insert(parent_paths, "~/workspace")
        end

        local root = vim.fs.root(args.buf, function(name, path)
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

        if root then
            vim.cmd.lcd(root)
        end
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = auto_root_group,
    desc = "Override local directory with the absolute project root detected by the active LSP",
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if client and client.root_dir then
            vim.cmd.lcd(client.root_dir)
        end
    end,
})
