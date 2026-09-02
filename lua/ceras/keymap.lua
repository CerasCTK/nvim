vim.g.mapleader = " "

vim.keymap.set("i", "jk", "<esc>", { desc = "Quick exit insert mode" })
vim.keymap.set("x", "<c-j><c-k>", "<esc>", { desc = "Quick exit visual mode" })

vim.keymap.set(
    { "i", "n", "v" },
    "<c-a>",
    "<esc>ggVG",
    { desc = "Select all content in current buffer" }
)
