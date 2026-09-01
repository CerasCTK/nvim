-- Disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Display and scroll settings
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.cursorline = true

vim.opt.wrap = false

vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10

vim.opt.termguicolors = true

vim.opt.fillchars = {
    eob = " "
}

vim.opt.signcolumn = "yes"

vim.opt.pumheight = 15
vim.opt.pumblend = 10

vim.opt.winblend = 0

vim.opt.laststatus = 3

vim.opt.synmaxcol = 300

if vim.g.ui2_enabled == true then
    vim.opt.cmdheight = 0
end

vim.opt.wildmode = "longest:full,full"

-- Editor and file behaviors
vim.opt.confirm = true

vim.opt.isfname:append("@-@")
vim.opt.path:append("**")

-- Auto-generated files
vim.opt.swapfile = false
vim.opt.writebackup = false

local undo_dir = vim.fn.stdpath("data") .. "/undodir"
if vim.fn.isdirectory(undo_dir) == 0 then
    vim.fn.mkdir(undo_dir, "p")
end
vim.opt.undodir = undo_dir
vim.opt.undofile = true

-- Indent and tab behaviors
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.shiftwidth = 4
vim.opt.shiftround = true

-- Search behaviors
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Split behaviors
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "screen"

-- Select behaviors
vim.opt.virtualedit = "block"
vim.opt.iskeyword:append("-")

-- System clipboard integration
vim.opt.clipboard:append("unnamedplus")

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
