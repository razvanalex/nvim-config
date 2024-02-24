--. NVim configurations
-- Author: razvanalex

-- UTF-8 encoding
vim.opt.enc = "utf-8"
vim.opt.fenc = "utf-8"
vim.opt.termencoding = "utf-8"

-- Open new vertical splits to the right of current one.
vim.opt.splitright = true

-- line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- tabs
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- use intelligent indentation
vim.opt.smartindent = true

-- no line wrap
vim.opt.wrap = false

-- undo history
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- search
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- enhanced colors
vim.opt.termguicolors = true

-- other stuffs
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
vim.opt.listchars = "eol:↵,tab:→ ,nbsp:·,space:·,trail:~"
vim.opt.foldmethod = "syntax"
vim.opt.foldenable = false

-- spell check
vim.opt.spell = true
vim.api.nvim_set_hl(0, "SpellBad", {undercurl=true, sp='#0faaff'})

-- mouse support
vim.opt.mouse = "a"
