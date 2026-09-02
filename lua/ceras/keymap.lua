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

vim.keymap.set("n", "<c-d>", "<c-d>zz", { desc = "Scroll down half page and center cursor" })
vim.keymap.set("n", "<c-u>", "<c-u>zz", { desc = "Scroll up half page and center cursor" })
vim.keymap.set("n", "{", "{zz", { desc = "Jump to previous paragraph and center cursor" })
vim.keymap.set("n", "}", "}zz", { desc = "Jump to next paragraph and center cursor" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines without moving cursor" })

vim.keymap.set("v", ">", ">gv", { desc = "Indent and maintain visual selection" })
vim.keymap.set("v", "<", "<gv", { desc = "Outdent and maintain visual selection" })

vim.keymap.set("n", "<a-j>", "<cmd>move .+1<cr>==", { desc = "Move current line down" })
vim.keymap.set("n", "<a-k>", "<cmd>move .-2<cr>==", { desc = "Move current line up" })
vim.keymap.set("i", "<a-j>", "<esc><cmd>move .+1<cr>==a", { desc = "Move current line down" })
vim.keymap.set("i", "<a-k>", "<esc><cmd>move .-2<cr>==a", { desc = "Move current line up" })
vim.keymap.set("x", "<a-j>", ":move '>+1<cr>gv=gv", { desc = "Move current block down" })
vim.keymap.set("x", "<a-k>", ":move '<-2<cr>gv=gv", { desc = "Move current block up" })
