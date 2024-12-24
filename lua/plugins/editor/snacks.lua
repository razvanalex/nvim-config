return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
    cond = not vim.g.vscode,
	opts = {
		bigfile = { enabled = true, notify = false },
        quickfile = { enabled = true },
    },
}
