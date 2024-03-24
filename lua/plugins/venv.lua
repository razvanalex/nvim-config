-- NOTE: requires fd to be installed
return {
	"linux-cultist/venv-selector.nvim",
	cond = not vim.g.vscode,
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim",
		"mfussenegger/nvim-dap-python",
	},
	opts = {
		name = { "venv", ".venv" },
		auto_refresh = true,
	},
	keys = {
		-- Keymap to open VenvSelector to pick a venv.
		{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "[V]env [S]elect" },
		-- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
		{ "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "[V]env Select Cached" },
	},
	init = function()
		vim.api.nvim_create_autocmd("VimEnter", {
			desc = "Auto select virtualenv Nvim open",
			pattern = "*",
			callback = function()
				local pyproject = vim.fn.findfile("pyproject.toml", vim.fn.getcwd() .. ";")
				local setuppy = vim.fn.findfile("setup.py", vim.fn.getcwd() .. ";")

				if pyproject ~= "" or setuppy ~= "" then
					require("venv-selector").retrieve_from_cache()
				end
			end,
			once = true,
		})
	end,
}
