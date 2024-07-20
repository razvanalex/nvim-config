return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	cond = not vim.g.vscode,
	event = "VeryLazy",
	config = function() -- This is the function that runs, AFTER loading
		local wk = require("which-key")

		wk.setup()

		-- Document existing key chains
		wk.add({
			{ "<leader>T", group = "[T]est" },
			{ "<leader>U", group = "[U]I" },
			{ "<leader>d", group = "[D]ebugger" },
			{ "<leader>df", group = "[D]ebugger [F]loating Window" },
			{ "<leader>f", group = "[F]uzzy Finder" },
			{ "<leader>g", group = "[G]it" },
			{ "<leader>gt", group = "[G]it [T]oggle" },
			{ "<leader>n", group = "[N]eogen" },
			{ "<leader>q", group = "[Q]uickfix" },
			{ "<leader>r", group = "[R]efactor" },
			{ "<leader>t", group = "[T]rouble" },
			{ "<leader>tl", group = "[T]rouble [L]SP" },
			{ "<leader>v", group = "[V]irtual Env" },
			{ "<leader>z", group = "[Z]en Mode" },
		})
	end,
}
