return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	cond = not vim.g.vscode,
	event = "VeryLazy",
	config = function() -- This is the function that runs, AFTER loading
		require("which-key").setup()

		-- Document existing key chains
		require("which-key").register({
			["<leader>r"] = { name = "[R]efactor", _ = "which_key_ignore" },
			["<leader>t"] = { name = "[T]rouble", _ = "which_key_ignore" },
			["<leader>tl"] = { name = "[T]rouble [L]SP", _ = "which_key_ignore" },
			["<leader>T"] = { name = "[T]est", _ = "which_key_ignore" },
			["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
			["<leader>gt"] = { name = "[G]it [T]oggle", _ = "which_key_ignore" },
			["<leader>f"] = { name = "[F]uzzy Finder", _ = "which_key_ignore" },
			["<leader>l"] = { name = "[L]ocation", _ = "which_key_ignore" },
			["<leader>q"] = { name = "[Q]uickfix", _ = "which_key_ignore" },
			["<leader>n"] = { name = "[N]eogen", _ = "which_key_ignore" },
			["<leader>v"] = { name = "[V]irtual Env", _ = "which_key_ignore" },
			["<leader>U"] = { name = "[U]I", _ = "which_key_ignore" },
			["<leader>z"] = { name = "[Z]en Mode", _ = "which_key_ignore" },
			["<leader>d"] = { name = "[D]ebugger", _ = "which_key_ignore" },
			["<leader>df"] = { name = "[D]ebugger [F]loating Window", _ = "which_key_ignore" },
		})
	end,
}
