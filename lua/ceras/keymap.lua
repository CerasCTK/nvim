vim.g.mapleader = " "

vim.keymap.set("i", "jk", "<esc>", { desc = "Quick exit insert mode" })
vim.keymap.set("x", "<c-j><c-k>", "<esc>", { desc = "Quick exit visual mode" })

vim.keymap.set(
    { "i", "n", "x" },
    "<c-a>",
    "<esc>ggVG",
    { desc = "Select all content in current buffer (Visual mode)" }
)

vim.keymap.set(
    "s",
    "<c-a>",
    "<esc>ggVG<c-g>",
    { desc = "Select all content in current buffer (Select mode)" }
)

vim.keymap.set("n", "<esc>", "<cmd>noh<cr>", { desc = "Clear highlight search result" })

vim.keymap.set(
    { "n", "x" },
    "j",
    function()
        return vim.v.count == 0 and "gj" or "j"
    end,
    { desc = "Move down with wrap-aware", expr = true }
)
vim.keymap.set(
    { "n", "x" },
    "k",
    function()
        return vim.v.count == 0 and "gk" or "k"
    end,
    { desc = "Move up with wrap-aware", expr = true }
)

vim.keymap.set("x", "<leader>p", "\"_dP", { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", { desc = "Delete without yanking" })

vim.keymap.set(
    { "n", "x", "o" },
    "n",
    function()
        local cmd = vim.v.searchforward == 1 and "n" or "N"
        return vim.api.nvim_get_mode().mode == "n" and (cmd .. "zzzv") or cmd
    end,
    { desc = "Next search match (centered in normal)", expr = true }
)
vim.keymap.set(
    { "n", "x", "o" },
    "N",
    function()
        local cmd = vim.v.searchforward == 1 and "N" or "n"
        return vim.api.nvim_get_mode().mode == "n" and (cmd .. "zzzv") or cmd
    end,
    { desc = "Previous search match (centered in normal)", expr = true }
)
