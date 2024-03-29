local c = require("vscode.colors").get_colors()
require("vscode").setup({
	-- Alternatively set style in setup
	style = "dark",

	-- Enable transparent background
	transparent = true,

	-- Enable italic comment
	italic_comments = false,

	-- Disable nvim-tree background color
	disable_nvimtree_bg = true,
})
require("vscode").load()
