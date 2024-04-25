return {
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		cond = not vim.g.vscode,
		opts = {},
		init = function()
			local ft = require("Comment.ft")
			ft.set("hcl", "#%s")
		end,
	},
	{ -- Highlight todo, notes, etc in comments
		"folke/todo-comments.nvim",
		cond = not vim.g.vscode,
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
		},
		init = function()
			vim.keymap.set("n", "<leader>tc", [[<Cmd>TodoTrouble<CR>]], { desc = "[T]rouble TODO [C]omments" })
		end,
	},
}
