local Plug = vim.fn["plug#"]

vim.call("plug#begin")

-- Git integration
Plug("airblade/vim-gitgutter") -- line changes/added/removed, diffs, etc
Plug("tpope/vim-fugitive") -- git commands inside vim (e.g., diff, commit, mergetool, blame)

-- IDE stuff
Plug("nvim-tree/nvim-tree.lua") -- file navigation left bar
Plug("tpope/vim-surround") -- handle surroundings (e.g., tags, parentheses, etc)
Plug("mg979/vim-visual-multi") -- extended multi-line support
Plug("nvim-telescope/telescope.nvim") -- fuzzy finder
Plug("mbbill/undotree") -- fancy undo
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = vim.fn[":TSUpdate"] }) -- nice text coloring
Plug("nvim-treesitter/nvim-treesitter-context")
Plug("theprimeagen/refactoring.nvim") -- refactoring
Plug("theprimeagen/harpoon") -- manage buffers easier
Plug("nvim-lua/plenary.nvim") -- dependency for harpoon
Plug("lukas-reineke/indent-blankline.nvim") -- identation lines
-- Plug("lukas-reineke/virt-column.nvim") -- column color
Plug("folke/trouble.nvim") -- shows issues in code (like Problems in vscode)
Plug("windwp/nvim-autopairs") -- brackets auto-close
Plug("numToStr/Comment.nvim") -- comment

-- LSP
Plug("neovim/nvim-lspconfig")
Plug("hrsh7th/nvim-cmp")
Plug("mfussenegger/nvim-lint")
Plug("mhartington/formatter.nvim")
Plug("hrsh7th/cmp-nvim-lsp")
Plug("hrsh7th/cmp-nvim-lua")
Plug("hrsh7th/cmp-buffer")
Plug("hrsh7th/cmp-path")
Plug("hrsh7th/cmp-cmdline")
Plug("saadparwaiz1/cmp_luasnip")
Plug("L3MON4D3/LuaSnip", { ["do"] = "make install_jsregexp" })
Plug("VonHeikemen/lsp-zero.nvim", { ["branch"] = "v3.x" })
Plug("williamboman/mason.nvim")
Plug("williamboman/mason-lspconfig.nvim")

-- Others
Plug("ThePrimeagen/vim-be-good")
Plug("tpope/vim-obsession")

-- UI Theme
Plug("nvim-lualine/lualine.nvim") -- powerline
Plug("kyazdani42/nvim-web-devicons") -- icons
Plug("bagrat/vim-buffet") -- tabline
Plug("Mofiqul/vscode.nvim") -- color theme
Plug("HiPhish/rainbow-delimiters.nvim") -- color theme
Plug("fladson/vim-kitty") -- vim kitty theme

vim.call("plug#end")

-- Plugin Configs
require("plugins.set")
require("plugins.lualine")
require("plugins.nvimtree")
require("plugins.vim_visual_multi")
require("plugins.remap")
require("plugins.vim_fugitive")
require("plugins.nvim_treesitter_context")
require("plugins.undotree")
require("plugins.telescope")
require("plugins.vscode_nvim")
require("plugins.harpoon")
require("plugins.refactoring")
require("plugins.indent_blankline")
require("plugins.lsp")
require("plugins.trouble")
require("plugins.rainbow_delimiters")
require("plugins.nvim_autoclose")
require("plugins.comment")
require("plugins.lint")
require("plugins.formatter")
