return {
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		lazy = true,
		cond = not vim.g.vscode,
		opts = {},
		init = function()
			local ft = require("Comment.ft")
			ft.set("hcl", "#%s")
		end,
	},
	{ -- Highlight todo, notes, etc in comments
		"folke/todo-comments.nvim",
		lazy = true,
		cond = not vim.g.vscode,
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
		},
		keys = {
			{
				"<leader>tc",
				"<CMD>TodoTrouble<CR>",
				desc = "[T]rouble TODO [C]omments",
			},
		},
	},
}
