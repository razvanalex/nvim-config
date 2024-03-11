-- NVim configurations
-- Author: razvanalex

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- UTF-8 encoding
vim.opt.enc = "utf-8"
vim.opt.fenc = "utf-8"
vim.opt.termencoding = "utf-8"

-- Open new vertical splits to the right of current one.
vim.opt.splitright = true

-- line numbers
vim.opt.number = true
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

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = false
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Incremental search
vim.opt.incsearch = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- enhanced colors
vim.opt.termguicolors = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 8

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- Decrease update time
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
vim.opt.timeoutlen = 300

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = false
vim.opt.listchars = { eol = "↵", tab = "→ ", nbsp = "·", space = "·", trail = "~" }

-- Folding
vim.opt.foldcolumn = "1"
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "" }

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false
vim.opt.laststatus = 3

-- spell check
vim.opt.spell = true
vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, sp = "#0faaff" })

-- mouse support
vim.opt.mouse = "a"

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"
