return {
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPre",
	cond = not vim.g.vscode,
	lazy = true,
	opts = { -- set to setup table
		filetypes = { "lua", "html", "javascript", "typescript", "css" },
		user_default_options = {
			mode = "virtualtext",
			virtualtext_inline = true,
			always_update = true,
		},
	},
}
