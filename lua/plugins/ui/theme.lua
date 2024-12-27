return {
	{ -- vscode color theme
		"Mofiqul/vscode.nvim",
		lazy = true,
		priority = 1000, -- make sure to load this before all the other start plugins
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
	{ -- catppuccin color scheme
		"catppuccin/nvim",
		name = "catppuccin",
		event = "VimEnter",
		priority = 1000,
		cond = not vim.g.vscode,
		opts = {
			transparent_background = os.getenv("TRANSPARENT") == "true" and true or false,
			integrations = {
				harpoon = true,
				gitsigns = true,
				neotest = true,
			},
			custom_highlights = function(C)
				local common = {
					-- Highlight groups for removed lines
					DiffviewDiffDelete = { bg = "none", fg = "#3B4252" },

					-- Highlight groups for delete
					DiffviewDelete = { bg = "#301a1e" },
					DiffviewDeleteText = { bg = "#7f2f2f" },

					-- Highlight groups for right panel
					DiffviewAdd = { bg = "#12261d" },
					DiffviewAddText = { bg = "#1c562b" },

					-- Git signs
					GitSignsAdd = { fg = "#6a9955" },
					GitSignsChange = { fg = "#0078d4" },
					GitSignsDelete = { fg = "#f85149" },

					-- Vimdiff
					DiffAdd = { bg = "#12261d" },
					DiffDelete = { bg = "#301a1e" },
					DiffChange = { bg = "#1f2742" },
					DiffText = { bg = "#2d385d" },

					FloatBorder = { fg = C.mantle, bg = C.mantle },
					CmpNormal = { bg = C.surface0 },
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
					if cat.options.transparent_background then
						vim.notify("Transparent background enabled", vim.log.levels.INFO)
					else
						vim.notify("Transparent background disabled", vim.log.levels.INFO)
					end
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
	{ -- web icons
		"nvim-tree/nvim-web-devicons",
		cond = not vim.g.vscode,
		enabled = vim.g.have_nerd_font,
	},
	{ -- syntax highlight for kitty terminal config
		"fladson/vim-kitty",
		lazy = true,
		ft = { "kitty" },
		cond = not vim.g.vscode,
	},
}
