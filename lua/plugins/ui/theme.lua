---Make transparent background for some highlight groups
---@param common table<string, any> Common highlight groups to overwrite
---@param C table<string, any> Colors from the colorscheme
---@return table<string, any> Overwritten highlight groups
local function fix_transparency(common, C)
	if os.getenv("TRANSPARENT") == "true" then
		local transparent_overwrites = {
			NormalFloat = { fg = C.text, bg = C.mantle }, -- Normal text in floating windows.
			SidekickChat = { fg = C.text, bg = "NONE" }, -- Sidekick terminal window transparent background
		}
		for k, v in pairs(transparent_overwrites) do
			common[k] = v
		end
	end
	return common
end

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
			highlight_overrides = {
				latte = function(latte)
					return fix_transparency({
						-- Highlight groups for removed lines
						DiffviewDiffDelete = { bg = "none", fg = "#D8DEE9" },

						-- Highlight groups for delete
						DiffviewDelete = { bg = "#f7d8db" },
						DiffviewDeleteText = { bg = "#f0b6ba" },

						-- Highlight groups for right panel
						DiffviewAdd = { bg = "#a4cdb7" },
						DiffviewAddText = { bg = "#85c1a7" },

						-- Git signs
						GitSignsAdd = { fg = "#2da44e" },
						GitSignsChange = { fg = "#0969da" },
						GitSignsDelete = { fg = "#cf222e" },

						-- Vimdiff
						DiffAdd = { bg = "#a4cdb7" },
						DiffDelete = { bg = "#f7d8db" },
						DiffChange = { bg = "#e9f1ff" },
						DiffText = { bg = "#d1dfff" },

						FloatBorder = { fg = latte.mantle, bg = latte.mantle },
						CmpNormal = { bg = latte.surface0 },
					}, latte)
				end,
				mocha = function(mocha)
					return fix_transparency({
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

						FloatBorder = { fg = mocha.mantle, bg = mocha.mantle },
						CmpNormal = { bg = mocha.surface0 },
					}, mocha)
				end,
			},
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
			-- This is temporary fix, the colors were not loaded properly for dark theme.
			-- Performance-wise,  it doesn't seem to cause any issues.
			require("catppuccin").compile()

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
