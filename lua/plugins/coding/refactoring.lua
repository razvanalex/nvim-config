return { -- refactoring
	"theprimeagen/refactoring.nvim",
	cond = not vim.g.vscode,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	lazy = true,
	cmd = "Refactor",
	opts = {},
	keys = {
		-- Extract function supports only visual mode
		{
			"<leader>re",
			function()
				require("refactoring").refactor("Extract Function")
			end,
			desc = "[R]efactor [E]xtract Function",
		},
		{
			"<leader>rf",
			function()
				require("refactoring").refactor("Extract Function To File")
			end,
			desc = "[R]efactor Extract [F]unction To File",
		},

		-- Extract variable supports only visual mode
		{
			"<leader>rv",
			function()
				require("refactoring").refactor("Extract Variable")
			end,
			desc = "[R]efactor Extract [V]ariable",
		},

		-- Inline func supports only normal
		{
			"<leader>rI",
			function()
				require("refactoring").refactor("Inline Function")
			end,
			desc = "[R]efactor [I]nline Function",
		},

		-- Inline var supports both normal and visual mode
		{
			"<leader>ri",
			function()
				require("refactoring").refactor("Inline Variable")
			end,
			desc = "[R]efactor [I]nline Variable",
		},

		-- Extract block supports only normal mode
		{
			"<leader>rb",
			function()
				require("refactoring").refactor("Extract Block")
			end,
			desc = "[R]efactor Extract [B]lock",
		},
		{
			"<leader>rbf",
			function()
				require("refactoring").refactor("Extract Block To File")
			end,
			desc = "[R]efactor Extract [B]lock To [F]ile",
		},
	},
}
