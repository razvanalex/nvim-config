return { -- manage buffers easier
	"theprimeagen/harpoon",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim", -- for theming
	},
	lazy = true,
	cond = not vim.g.vscode,
	branch = "harpoon2",
	keys = {
		{
			"<M-a>",
			function()
				require("harpoon"):list():add()
			end,
			desc = "Harpoon [A]dd Buffer",
		},
		{
			"<M-e>",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list(), {
					title_pos = "center",
					---@diagnostic disable-next-line: assign-type-mismatch
					title = { { " Harpoon ", "TelescopePreviewTitle" } },
					border = { { "+", "TelescopePreviewBorder" } },
					ui_max_width = 100,
				})
			end,
			desc = "Op[e]n Harpoon List",
		},
		{
			"<C-h>",
			function()
				require("harpoon"):list():select(1)
			end,
			desc = "Harpoon Select 1",
		},
		{
			"<C-j>",
			function()
				require("harpoon"):list():select(2)
			end,
			desc = "Harpoon Select 2",
		},
		{
			"<C-k>",
			function()
				require("harpoon"):list():select(3)
			end,
			desc = "Harpoon Select 3",
		},
		{
			"<C-l>",
			function()
				require("harpoon"):list():select(4)
			end,
			desc = "Harpoon Select 4",
		},
		{
			"<leader><C-h>",
			function()
				require("harpoon"):list():replace_at(1)
			end,
			desc = "Harpoon Replace 1",
		},
		{
			"<leader><C-j>",
			function()
				require("harpoon"):list():replace_at(2)
			end,
			desc = "Harpoon Replace 2",
		},
		{
			"<leader><C-k>",
			function()
				require("harpoon"):list():replace_at(3)
			end,
			desc = "Harpoon Replace 3",
		},
		{
			"<leader><C-l>",
			function()
				require("harpoon"):list():replace_at(4)
			end,
			desc = "Harpoon Replace 4",
		},
		{
			"<C-S-j>",
			function()
				require("harpoon"):list():prev()
			end,
			desc = "Harpoon previous buffer",
		},
		{
			"<C-S-k>",
			function()
				require("harpoon"):list():next()
			end,
			desc = "Harpoon next buffer",
		},
	},
}
