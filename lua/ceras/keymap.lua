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
