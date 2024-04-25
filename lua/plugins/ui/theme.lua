return {
	{ -- vscode color theme
		"Mofiqul/vscode.nvim",
		priority = 1000, -- make sure to load this before all the other start plugins
		lazy = true,
		cond = not vim.g.vscode,
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
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		event = "VimEnter",
		priority = 1000,
		cond = not vim.g.vscode,
		opts = {
			transparent_background = os.getenv("TRANSPARENT") == "true" and true or false,
			integrations = {
				harpoon = true,
				gitsigns = false,
				neotest = true,
			},
			custom_highlights = function(C)
				local common = {
					-- Highlight groups for removed lines
					DiffviewDiffDelete = { bg = "none", fg = "#3B4252" },

					-- Highlight groups for delete
					DiffviewDelete = { bg = "#500000" },
					DiffviewDeleteText = { bg = "#d62927" },

					-- Highlight groups for right panel
					DiffviewAdd = { bg = "#043300" },
					DiffviewAddText = { bg = "#487733" },

					-- Git signs
					GitSignsAdd = { fg = "#6a9955" },
					GitSignsChange = { fg = "#0078d4" },
					GitSignsDelete = { fg = "#f85149" },
				}
				if os.getenv("TRANSPARENT") == "true" then
					local transparent_overwrites = {
						NormalFloat = { fg = C.text, bg = C.mantle }, -- Normal text in floating windows.
					}
					for k, v in pairs(transparent_overwrites) do
						common[k] = v
					end
				end
				return common
			end,
		},
		keys = {
			{
				"<leader>Ut",
				function()
					local cat = require("catppuccin")
					cat.options.transparent_background = not cat.options.transparent_background
					cat.compile()
					vim.cmd.colorscheme(vim.g.colors_name)
				end,
				mode = "n",
				desc = "Toggle [U]I [T]ransparency",
			},
		},
		init = function()
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		enabled = vim.g.have_nerd_font,
	},
	{ -- syntax highlight for kitty terminal config
		"fladson/vim-kitty",
		lazy = true,
		cond = not vim.g.vscode,
	},
}
