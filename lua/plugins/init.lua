require("plugins.nvim_options")
require("plugins.keymaps")

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins, you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	-- UI Theme
	require("plugins.theme"),
	require("plugins.rainbow_delimiters"),

	-- Useful for getting pretty icons, but requires a Nerd Font.
	{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	"fladson/vim-kitty", -- syntax highlight for kitty terminal config

	-- Buffer/File Manager
	require("plugins.telescope"),
	require("plugins.harpoon"),
	require("plugins.nvimtree"),

	-- Editing
	{ -- fancy undo
		"mbbill/undotree",
		event = "VimEnter",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "[U]ndoTree Toggle" })
		end,
	},
	{ "numToStr/Comment.nvim", opts = {} }, -- comments
	"tpope/vim-surround", -- handle surroundings (e.g., tags, parentheses, etc). FIXME: decide if kept or changed with mini.surround.
	{ -- refactoring
		"theprimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			---@diagnostic disable-next-line: missing-parameter
			require("refactoring").setup()

			-- Extract function supports only visual mode
			vim.keymap.set("x", "<leader>re", function()
				require("refactoring").refactor("Extract Function")
			end, { desc = "[R]efactor [E]xtract Function" })

			vim.keymap.set("x", "<leader>rf", function()
				require("refactoring").refactor("Extract Function To File")
			end, { desc = "[R]efactor Extract [F]unction To File" })

			-- Extract variable supports only visual mode
			vim.keymap.set("x", "<leader>rv", function()
				require("refactoring").refactor("Extract Variable")
			end, { desc = "[R]efactor Extract [V]ariable" })

			-- Inline func supports only normal
			vim.keymap.set("n", "<leader>rI", function()
				require("refactoring").refactor("Inline Function")
			end, { desc = "[R]efactor [I]nline Function" })

			-- Inline var supports both normal and visual mode
			vim.keymap.set({ "n", "x" }, "<leader>ri", function()
				require("refactoring").refactor("Inline Variable")
			end, { desc = "[R]efactor [I]nline Variable" })

			-- Extract block supports only normal mode
			vim.keymap.set("n", "<leader>rb", function()
				require("refactoring").refactor("Extract Block")
			end, { desc = "[R]efactor Extract [B]lock" })

			vim.keymap.set("n", "<leader>rbf", function()
				require("refactoring").refactor("Extract Block To File")
			end, { desc = "[R]efactor Extract [B]lock To [F]ile" })
		end,
	},
	{ "windwp/nvim-autopairs", opts = {} }, -- brackets auto-close
	"mg979/vim-visual-multi", -- extended multi-line support
	{ -- Highlight todo, notes, etc in comments
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
		},
		init = function()
			vim.keymap.set("n", "<leader>tc", [[<Cmd>TodoTrouble<CR>]], { desc = "[T]rouble TODO [C]omments" })
		end,
	},
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

	-- Git integration
	require("plugins.gitsigns"), -- line changes/added/removed, diffs, etc
	{ -- git commands inside vim (e.g., diff, commit, mergetool, blame)
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gg", vim.cmd.Git, { desc = "[G]it Sta[g]e Area" })
		end,
	},
	"tpope/vim-rhubarb", -- enable :GBrowse to open current repo in GitHub

	-- Vim help
	require("plugins.which_key"),
	"ThePrimeagen/vim-be-good", -- vim tutorial

	-- IDE
	require("plugins.nvim_treesitter"),
	require("plugins.statuscol"),
	require("plugins.lualine"),
	require("plugins.indent_blankline"),
	"bagrat/vim-buffet", -- tabline
	"lambdalisue/suda.vim", -- Save wit sudo if forgot to open with `sudo nvim ...`
	{ -- VSCode like winbar
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons", -- optional dependency
		},
		opts = {
			-- configurations go here
		},
	},
	{
		"norcalli/nvim-colorizer.lua",
		opts = {
			"*", -- Highlight all files, but customize some others.
		},
	},

	{ -- Session
		"rmagatti/auto-session",
		opts = {
			auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
		},
	},

	-- FIXME: LLMs
	-- "huggingface/llm.nvim",

	-- LSP, autocompletion, dap, tests, etc
	require("plugins.lsp"),
	require("plugins.autocompletion"),
	require("plugins.formatter"),
	require("plugins.lint"),
	{ "folke/neodev.nvim", opts = {} },
	require("plugins.dap"),
	require("plugins.test"),
	require("plugins.venv"),
})
