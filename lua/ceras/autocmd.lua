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
        if vim.v.event.operator == "y" and vim.g.cursor_pre_yank then
            vim.api.nvim_win_set_cursor(0, vim.g.cursor_pre_yank)
            vim.g.cursor_pre_yank = nil
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
