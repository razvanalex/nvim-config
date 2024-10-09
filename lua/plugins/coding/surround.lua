return {
	"kylechui/nvim-surround",
	cond = not vim.g.vscode,
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	event = "VeryLazy",
	opts = {},
}
