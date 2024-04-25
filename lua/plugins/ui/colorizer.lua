return {
	"norcalli/nvim-colorizer.lua",
	cond = not vim.g.vscode,
	event = "VeryLazy",
	opts = {
		"*", -- Highlight all files, but customize some others.
	},
}
