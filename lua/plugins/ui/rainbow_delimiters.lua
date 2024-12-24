return { -- colored parentheses
	"HiPhish/rainbow-delimiters.nvim",
	cond = not vim.g.vscode,
	event = "VeryLazy",
	config = function()
		require("rainbow-delimiters.setup").setup({
			highlight = {
				"RainbowDelimiterYellow",
				"RainbowDelimiterViolet",
				"RainbowDelimiterBlue",
			},
		})
	end,
}
