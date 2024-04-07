return { -- refactoring
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
}
