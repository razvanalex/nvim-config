return {
	"folke/zen-mode.nvim",
    cond = not vim.g.vscode,
	lazy = true,
	cmd = "ZenMode",
	opts = {
		window = {
			options = {
				signcolumn = "no",
				number = true,
				relativenumber = true,
				foldcolumn = "0",
				list = false,
			},
		},
		plugins = {
			tmux = { enabled = true },
			kitty = {
				enabled = true,
				font = "+0", -- font size increment
			},
		},
		-- callback where you can add custom code when the Zen window opens
		on_open = function(_)
			vim.cmd(":IBLDisable")
			vim.cmd(":Gitsigns toggle_current_line_blame")
		end,
		-- callback where you can add custom code when the Zen window closes
		on_close = function()
			vim.cmd(":IBLEnable")
			vim.cmd(":Gitsigns toggle_current_line_blame")
		end,
	},
	keys = {
		{
			"<leader>z1",
			function()
				local zen = require("zen-mode")
				zen.toggle()
			end,
			desc = "[Z]en Mode Profile [1]",
		},
		{
			"<leader>z2",
			function()
				local zen = require("zen-mode")
				zen.toggle({ plugins = { kitty = { font = "+12" } } })
			end,
			desc = "[Z]en Mode Profile [2]",
		},
	},
}
