return {
	"Bekaboo/dropbar.nvim",
	cond = not vim.g.vscode,
	dependencies = {
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
	},
	opts = {
		bar = {
			update_events = {
				buf = {
					"FileChangedShellPost",
					"TextChanged",
					"ModeChanged",
				},
			},
		},
	},
	config = function(_, opts)
		require("dropbar").setup(opts)
		local dropbar_api = require("dropbar.api")
		vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
		vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
		vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })

		-- Manual fix for BufModifiedSet deprecation in Neovim 0.13
		vim.api.nvim_create_autocmd("OptionSet", {
			pattern = "modified",
			callback = function()
				require("dropbar.utils.bar").exec("update", { buf = vim.api.nvim_get_current_buf() })
			end,
		})
	end,
}
