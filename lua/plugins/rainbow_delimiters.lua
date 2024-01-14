vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#f7d700" })
vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#d35e78" })
vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#009fdc" })

require("rainbow-delimiters.setup").setup({
	highlight = {
		"RainbowDelimiterYellow",
		"RainbowDelimiterViolet",
		"RainbowDelimiterBlue",
	},
})
