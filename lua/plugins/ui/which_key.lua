return { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
	lazy = true,
	cond = not vim.g.vscode,
	event = "VeryLazy",
	config = function() -- This is the function that runs, AFTER loading
		local wk = require("which-key")

		wk.setup()

		-- Document existing key chains
		wk.add({
			{ "<leader>A", group = "[A]vante" },
			{ "<leader>T", group = "[T]est" },
			{ "<leader>U", group = "[U]I" },
			{ "<leader>d", group = "[D]ebugger" },
			{ "<leader>dr", group = "[D]ebugger [R]un" },
			{ "<leader>ds", group = "[D]ebugger [S]tep" },
			{ "<leader>df", group = "[D]ebugger [F]loating Window/[F]rames" },
			{ "<leader>f", group = "[F]uzzy Finder" },
			{ "<leader>g", group = "[G]it" },
			{ "<leader>gt", group = "[G]it [T]oggle" },
			{ "<leader>n", group = "[N]eogen" },
			{ "<leader>r", group = "[R]efactor" },
			{ "<leader>re", group = "[R]efactor [E]xtract" },
			{ "<leader>ri", group = "[R]efactor [I]nline" },
			{ "<leader>t", group = "[T]rouble" },
			{ "<leader>tl", group = "[T]rouble [L]SP" },
			{ "<leader>v", group = "[V]irtual Env" },
			{ "<leader>z", group = "[Z]en Mode" },
			{ "<leader>m", group = "[M]olten" },
			{ "<localleader>q", group = "[Q]uarto" },
			{ "<localleader>qr", group = "[Q]uarto [R]un" },
			{ "<localleader>qR", group = "[Q]uarto [R]un All Languages" },
			{ "<localleader>M", group = "[M]olten" },
		})
	end,
}
