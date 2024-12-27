return {
	"lukas-reineke/indent-blankline.nvim",
	event = "VeryLazy",
	main = "ibl",
	cond = not vim.g.vscode,
	opts = {
		scope = {
			show_start = false,
			show_end = false,
		},
		indent = {
			char = "▏",
			smart_indent_cap = true,
		},
		exclude = {
			filetypes = {
				"Trouble",
				"alpha",
				"dashboard",
				"help",
				"lazy",
				"mason",
				"neo-tree",
				"notify",
				"snacks_dashboard",
				"snacks_notif",
				"snacks_terminal",
				"snacks_win",
				"toggleterm",
				"trouble",
			},
		},
	},
}
