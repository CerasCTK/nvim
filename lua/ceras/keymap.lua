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
vim.keymap.set("x", "<a-j>", ":move '>+1<cr>gv=gv", { desc = "Move current block down" })
vim.keymap.set("x", "<a-k>", ":move '<-2<cr>gv=gv", { desc = "Move current block up" })
local move_line_for_insert = function(is_go_down)
    return function()
        local pos = vim.api.nvim_win_get_cursor(0)
        local row, col = pos[1], pos[2]

        local total_lines = vim.api.nvim_buf_line_count(0)

        local step = is_go_down and 1 or -1
        local move_cmd = is_go_down and "move .+1" or "move .-2"

        if is_go_down and row >= total_lines then return end
        if not is_go_down and row <= 1 then return end

        local old_indent = #vim.fn.matchstr(vim.fn.getline(row), [[^\s*]])

        vim.cmd(move_cmd)
        vim.cmd("normal! ==")

        local new_indent = #vim.fn.matchstr(vim.fn.getline(row + 1), [[^\s*]])

        local new_col = col + (new_indent - old_indent)

        vim.api.nvim_win_set_cursor(0, { row + step, math.max(0, new_col) })
    end
end
vim.keymap.set("i", "<a-j>", move_line_for_insert(true), { desc = "Move current line down" })
vim.keymap.set("i", "<a-k>", move_line_for_insert(), { desc = "Move current line up" })

vim.keymap.set("n", "<a-h>", "zh", { desc = "Scroll view to the left" })
vim.ketmap.set("n", "<a-l>", "zl", { desc = "Scroll view to the right" })

vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split window vertically" })

vim.keymap.set("n", "<c-h>", "<c-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<c-j>", "<c-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<c-k>", "<c-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<c-l>", "<c-w>l", { desc = "Go to right window" })

vim.keymap.set("n", "<c-up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<c-down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<c-left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<c-right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

vim.keymap.set("i", ",", ",<c-g>u", { desc = "Add undo breakpoint at comma" })
vim.keymap.set("i", ".", ".<c-g>u", { desc = "Add undo breakpoint at period" })
vim.keymap.set("i", ";", ";<c-g>u", { desc = "Add undo breakpoint at semicolon" })

vim.keymap.set("n", "<leader>tw", "<cmd>set wrap!<cr>", { desc = "Toggle wrap" })

vim.keymap.set("n", "zv", "zMzvzz", { desc = "Focus current fold and close all others" })
vim.keymap.set("n", "zj", "zcjzOzz", { desc = "Close current fold and move to next fold" })
vim.keymap.set("n", "zk", "zckzOzz", { desc = "Close current fold and move to previous fold" })
