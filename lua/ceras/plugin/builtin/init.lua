require("ceras.core.workspace").setup_editorconfig()

if vim.fn.has("nvim-0.12") == 1 then
    vim.cmd.packadd("nvim.difftool")

    vim.cmd.packadd("nvim.undotree")
    local undotree = require("ceras.core.undotree")

    vim.keymap.set("n", "<leader>eu", undotree.open, { desc = "Toggle builtin Undotree" })

    vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("SetupUndoTree", { clear = true }),
        desc = "Configure native UndoTree",
        pattern = "nvim-undotree",
        callback = function(args)
            local bufnr = args.buf

            vim.bo[bufnr].buflisted = false
            vim.opt_local.foldenable = false

            vim.keymap.set("n", "q", undotree.cancel, { buffer = bufnr, desc = "Cancel undo selection and close UndoTree" })
            vim.keymap.set("n", "<cr>", undotree.confirm, { buffer = bufnr, desc = "Confirm undo selection" })
        end,
    })
end

vim.cmd("syntax off")

vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_shada_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_remote_plugins = 1
vim.g.loaded_tutor_mode_plugin = 1
