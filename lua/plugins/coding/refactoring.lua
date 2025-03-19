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
				return require("refactoring").refactor("Extract Function")
			end,
			desc = "[R]efactor [E]xtract [F]unction",
			mode = "v",
			expr = true,
		},
		{
			"<leader>reF",
			function()
				return require("refactoring").refactor("Extract Function To File")
			end,
			desc = "[R]efactor [E]xtract Function To [F]ile",
			mode = "v",
			expr = true,
		},

		-- Extract variable supports only visual mode
		{
			"<leader>rev",
			function()
				return require("refactoring").refactor("Extract Variable")
			end,
			desc = "[R]efactor [E]xtract [V]ariable",
			mode = "v",
			expr = true,
		},

		-- Inline func supports only normal
		{
			"<leader>rif",
			function()
				return require("refactoring").refactor("Inline Function")
			end,
			desc = "[R]efactor [I]nline [F]unction",
			expr = true,
		},

		-- Inline var supports both normal and visual mode
		{
			"<leader>riv",
			function()
				return require("refactoring").refactor("Inline Variable")
			end,
			desc = "[R]efactor [I]nline [V]ariable",
			expr = true,
		},

		-- Extract block supports only normal mode
		{
			"<leader>reb",
			function()
				return require("refactoring").refactor("Extract Block")
			end,
			desc = "[R]efactor [E]xtract [B]lock",
			expr = true,
		},
		{
			"<leader>reB",
			function()
				return require("refactoring").refactor("Extract Block To File")
			end,
			desc = "[R]efactor [E]xtract Block To [F]ile",
			expr = true,
		},
	},
}
