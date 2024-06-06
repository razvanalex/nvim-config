-- NOTE: requires fd to be installed
return {
	"linux-cultist/venv-selector.nvim",
	ft = "python",
	branch = "regexp",
	cond = not vim.g.vscode,
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim",
		"mfussenegger/nvim-dap-python",
	},
	keys = {
		-- Keymap to open VenvSelector to pick a venv.
		{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "[V]env [S]elect" },
	},
	init = function()
		require("venv-selector").setup()
	end,
}
