return {
	{ -- vscode color theme
		"Mofiqul/vscode.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
		opts = {
			-- Alternatively set style in setup
			style = "dark",

			-- Enable transparent background
			transparent = true,

			-- Enable italic comment
			italic_comments = false,

			-- Disable nvim-tree background color
			disable_nvimtree_bg = true,

			group_overrides = {
				-- this supports the same val table as vim.api.nvim_set_hl
				-- use colors from this colorscheme by requiring vscode.colors!
				SpellBad = { bg = "NONE", fg = "NONE", undercurl = true, sp = "#0faaff" },
				SpellCap = { bg = "NONE", fg = "NONE", undercurl = true, sp = "#0faaff" },
				SpellRare = { bg = "NONE", fg = "NONE", undercurl = true, sp = "#0faaff" },
				SpellLocal = { bg = "NONE", fg = "NONE", undercurl = true, sp = "#0faaff" },
			},
		},
		init = function()
			-- require("vscode").load()
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			transparent_background = os.getenv("TRANSPARENT"),
			integrations = {
				mason = true,
				harpoon = true,
			},
			custom_highlights = function(C)
				return {
					NormalFloat = { fg = C.text, bg = C.mantle }, -- Normal text in floating windows.
				}
			end,
		},
		lazy = false,
		init = function()
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
