return {
	"linux-cultist/venv-selector.nvim",
	lazy = true,
	ft = "python",
	cond = not vim.g.vscode,
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim",
		"mfussenegger/nvim-dap-python",
	},
	opts = {},
	keys = {
		-- Keymap to open VenvSelector to pick a venv.
		{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "[V]env [S]elect" },
	},
}
