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
		cond = not vim.g.vscode,
		event = "VimEnter",
		config = function()
			vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "[U]ndoTree Toggle" })
		end,
	},
	{ "numToStr/Comment.nvim", event = "VeryLazy", cond = not vim.g.vscode, opts = {} }, -- comments
	{
		"kylechui/nvim-surround",
		cond = not vim.g.vscode,
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		opts = {},
	},
	{ -- refactoring
		"theprimeagen/refactoring.nvim",
		cond = not vim.g.vscode,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		event = "VeryLazy",
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
	{ "windwp/nvim-autopairs", event = "VeryLazy", opts = {}, cond = not vim.g.vscode }, -- brackets auto-close
	{ "mg979/vim-visual-multi", cond = not vim.g.vscode }, -- extended multi-line support
	{ -- Highlight todo, notes, etc in comments
		"folke/todo-comments.nvim",
		cond = not vim.g.vscode,
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
		},
		init = function()
			vim.keymap.set("n", "<leader>tc", [[<Cmd>TodoTrouble<CR>]], { desc = "[T]rouble TODO [C]omments" })
		end,
	},
	{ "tpope/vim-sleuth", cond = not vim.g.vscode }, -- Detect tabstop and shiftwidth automatically

	-- Git integration
	require("plugins.gitsigns"), -- line changes/added/removed, diffs, etc
	{ -- git commands inside vim (e.g., diff, commit, mergetool, blame)
		"tpope/vim-fugitive",
		cond = not vim.g.vscode,
		config = function()
			vim.keymap.set("n", "<leader>gg", vim.cmd.Git, { desc = "[G]it Sta[g]e Area" })
		end,
	},
	"tpope/vim-rhubarb", -- enable :GBrowse to open current repo in GitHub

	-- Vim help
	require("plugins.which_key"),
	{ "ThePrimeagen/vim-be-good", cond = not vim.g.vscode }, -- vim tutorial

	-- IDE
	require("plugins.nvim_treesitter"),
	require("plugins.statuscol"),
	require("plugins.lualine"),
	require("plugins.ufo"),
	require("plugins.indent_blankline"),
	{ "bagrat/vim-buffet", cond = not vim.g.vscode }, -- tabline
	"lambdalisue/suda.vim", -- Save wit sudo if forgot to open with `sudo nvim ...`
	{ -- VSCode like winbar
		"utilyre/barbecue.nvim",
		cond = not vim.g.vscode,
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
		cond = not vim.g.vscode,
		event = "VeryLazy",
		opts = {
			"*", -- Highlight all files, but customize some others.
		},
	},
	require("plugins.diffview"),
	require("plugins.autosession"),
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		init = function()
			if os.getenv("TMUX") ~= nil then
				vim.keymap.set(
					"n",
					"<c-w>h",
					":TmuxNavigateLeft<CR>",
					{ desc = "Go to the left window", noremap = true, silent = true }
				)
				vim.keymap.set(
					"n",
					"<c-w>j",
					":TmuxNavigateDown<CR>",
					{ desc = "Go to the down window", noremap = true, silent = true }
				)
				vim.keymap.set(
					"n",
					"<c-w>k",
					":TmuxNavigateUp<CR>",
					{ desc = "Go to the up window", noremap = true, silent = true }
				)
				vim.keymap.set(
					"n",
					"<c-w>l",
					":TmuxNavigateRight<CR>",
					{ desc = "Go to the right window", noremap = true, silent = true }
				)
				vim.keymap.set(
					"n",
					"<c-w>/",
					":TmuxNavigatePrevious<CR>",
					{ desc = "Go to the previous window", noremap = true, silent = true }
				)
			end
		end,
	},

	-- LSP, autocompletion, dap, tests, etc
	require("plugins.lsp"),
	require("plugins.autocompletion"),
	require("plugins.formatter"),
	require("plugins.lint"),
	{ "folke/neodev.nvim", opts = {} },
	require("plugins.dap"),
	require("plugins.test"),
	require("plugins.venv"),

	-- LLMs
	require("plugins.llm"),
})
