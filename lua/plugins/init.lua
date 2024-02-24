local Plug = vim.fn["plug#"]

vim.call("plug#begin")

-- Git integration
Plug("lewis6991/gitsigns.nvim") -- line changes/added/removed, diffs, etc
Plug("tpope/vim-fugitive") -- git commands inside vim (e.g., diff, commit, mergetool, blame)
Plug("tpope/vim-rhubarb") -- enable GBrowse to open current repo in GitHub

-- Buffer/File Manager
Plug("nvim-telescope/telescope.nvim") -- fuzzy finder
Plug("nvim-lua/plenary.nvim") -- dependency for harpoon
Plug("theprimeagen/harpoon", { branch = "harpoon2" }) -- manage buffers easier
Plug("nvim-tree/nvim-tree.lua") -- file navigation left bar

-- Editing
Plug("mbbill/undotree") -- fancy undo
Plug("numToStr/Comment.nvim") -- comment
Plug("tpope/vim-surround") -- handle surroundings (e.g., tags, parentheses, etc)
Plug("theprimeagen/refactoring.nvim") -- refactoring
Plug("windwp/nvim-autopairs") -- brackets auto-close
Plug("mg979/vim-visual-multi") -- extended multi-line support

-- Vim help
Plug("folke/which-key.nvim") -- help with key bindings
Plug("ThePrimeagen/vim-be-good") -- vim tutorial

-- Save session
Plug("tpope/vim-obsession") -- save session

-- IDE
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = vim.fn[":TSUpdate"] }) -- nice text coloring
Plug("nvim-treesitter/nvim-treesitter-context")
Plug("folke/trouble.nvim") -- shows issues in code (like Problems in vscode)
Plug("luukvbaal/statuscol.nvim") -- folding code
-- Plug("lukas-reineke/indent-blankline.nvim") -- indentation lines
Plug("lukas-reineke/virt-column.nvim") -- column color
Plug("nvim-lualine/lualine.nvim") -- powerline
Plug("bagrat/vim-buffet") -- tabline

-- LSP
Plug("neovim/nvim-lspconfig")
Plug("mfussenegger/nvim-lint")
Plug("mhartington/formatter.nvim")
Plug("hrsh7th/nvim-cmp")
Plug("hrsh7th/cmp-nvim-lsp")
Plug("hrsh7th/cmp-nvim-lua")
Plug("hrsh7th/cmp-buffer")
Plug("hrsh7th/cmp-path")
Plug("hrsh7th/cmp-cmdline")
Plug("saadparwaiz1/cmp_luasnip")
Plug("L3MON4D3/LuaSnip", { ["do"] = "make install_jsregexp" })
Plug("rafamadriz/friendly-snippets")
Plug("VonHeikemen/lsp-zero.nvim", { ["branch"] = "v3.x" })
Plug("williamboman/mason.nvim")
Plug("williamboman/mason-lspconfig.nvim")
Plug("onsails/lspkind.nvim")

-- UI Theme
Plug("kyazdani42/nvim-web-devicons") -- icons
Plug("Mofiqul/vscode.nvim") -- color theme
Plug("HiPhish/rainbow-delimiters.nvim") -- colored parentheses
Plug("fladson/vim-kitty") -- syntax highlight for kitty terminal config

vim.call("plug#end")

-- Plugin Configs
require("plugins.remap")
require("plugins.vim_fugitive")
require("plugins.telescope")
require("plugins.harpoon")
require("plugins.nvimtree")
require("plugins.undotree")
require("plugins.comment")
require("plugins.lualine")
require("plugins.which_key")
require("plugins.nvim_treesitter_context")
require("plugins.refactoring")
require("plugins.trouble")
require("plugins.nvim_autoclose")
-- require("plugins.indent_blankline")
require("plugins.lsp")
require("plugins.lint")
require("plugins.formatter")
require("plugins.statuscol")
require("plugins.gitsigns")
require("plugins.vscode_nvim")
require("plugins.rainbow_delimiters")
require("plugins.set")
