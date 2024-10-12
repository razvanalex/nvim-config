return { -- Session
	"rmagatti/auto-session",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	cond = not vim.g.vscode,
	opts = {
		session_lens = {
			buftypes_to_ignore = { ".ipynb" },
			load_on_setup = true,
			previewer = false,
			theme_conf = {
				border = true,
			},
		},
		suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
	},
	config = function(_, opts)
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

		require("auto-session").setup(opts)
	end,
}
