return {
	"windwp/nvim-autopairs",
	lazy = true,
	event = "InsertEnter",
	opts = {},
	cond = not vim.g.vscode,
}
