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
			"<leader>ref",
			function()
				require("refactoring").refactor("Extract Function")
			end,
			desc = "[R]efactor [E]xtract [F]unction",
			mode = "v",
		},
		{
			"<leader>reF",
			function()
				require("refactoring").refactor("Extract Function To File")
			end,
			desc = "[R]efactor [E]xtract Function To [F]ile",
			mode = "v",
		},

		-- Extract variable supports only visual mode
		{
			"<leader>rev",
			function()
				require("refactoring").refactor("Extract Variable")
			end,
			desc = "[R]efactor [E]xtract [V]ariable",
			mode = "v",
		},

		-- Inline func supports only normal
		{
			"<leader>rif",
			function()
				require("refactoring").refactor("Inline Function")
			end,
			desc = "[R]efactor [I]nline [F]unction",
		},

		-- Inline var supports both normal and visual mode
		{
			"<leader>riv",
			function()
				require("refactoring").refactor("Inline Variable")
			end,
			desc = "[R]efactor [I]nline [V]ariable",
		},

		-- Extract block supports only normal mode
		{
			"<leader>reb",
			function()
				require("refactoring").refactor("Extract Block")
			end,
			desc = "[R]efactor [E]xtract [B]lock",
		},
		{
			"<leader>reB",
			function()
				require("refactoring").refactor("Extract Block To File")
			end,
			desc = "[R]efactor [E]xtract Block To [F]ile",
		},
	},
}
