return { -- Session
	"rmagatti/auto-session",
	lazy = true,
	enabled = false, -- Disabled ATM
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
    init = function()
        vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    end,
}
