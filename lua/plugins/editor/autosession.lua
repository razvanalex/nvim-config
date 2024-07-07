return { -- Session
	"rmagatti/auto-session",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	cond = not vim.g.vscode,
	opts = {
		auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
		session_lens = {
			load_on_setup = true,
			theme_conf = { border = true },
			previewer = false,
			buftypes_to_ignore = {},
		},
	},
}
