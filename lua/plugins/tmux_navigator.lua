return {
	"christoomey/vim-tmux-navigator",
	cmd = {
		"TmuxNavigateLeft",
		"TmuxNavigateDown",
		"TmuxNavigateUp",
		"TmuxNavigateRight",
		"TmuxNavigatePrevious",
	},
	init = function()
		vim.g.tmux_navigator_no_mappings = 1

		if os.getenv("TMUX") ~= nil then
			vim.keymap.set(
				"n",
				"<c-w>h",
				":TmuxNavigateLeft<CR>",
				{ desc = "Go to the left window", noremap = true, silent = true }
			)
			vim.keymap.set(
				"n",
				"<c-w>j",
				":TmuxNavigateDown<CR>",
				{ desc = "Go to the down window", noremap = true, silent = true }
			)
			vim.keymap.set(
				"n",
				"<c-w>k",
				":TmuxNavigateUp<CR>",
				{ desc = "Go to the up window", noremap = true, silent = true }
			)
			vim.keymap.set(
				"n",
				"<c-w>l",
				":TmuxNavigateRight<CR>",
				{ desc = "Go to the right window", noremap = true, silent = true }
			)
			vim.keymap.set(
				"n",
				"<c-w>/",
				":TmuxNavigatePrevious<CR>",
				{ desc = "Go to the previous window", noremap = true, silent = true }
			)
		end
	end,
}
