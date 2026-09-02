vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
    desc = "Highlight selected text when yanking",
    callback = function()
        vim.hl.on_yank()
    end,
})
