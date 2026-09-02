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
