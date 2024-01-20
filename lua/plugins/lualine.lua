local Colors = {
	black = "#000000",
	white = "#ffffff",

	darkestgreen = "#005f00",
	darkgreen = "#008700",
	mediumgreen = "#5faf00",
	brightgreen = "#afdf00",

	darkestcyan = "#005f5f",
	mediumcyan = "#87dfff",

	darkestblue = "#005f87",
	darkblue = "#0087af",

	darkestred = "#5f0000",
	darkred = "#870000",
	mediumred = "#af0000",
	brightred = "#df0000",
	brightestred = "#ff0000",

	darkestpurple = "#5f00af",
	mediumpurple = "#875fdf",
	brightpurple = "#dfdfff",

	brightorange = "#ff8700",
	brightestorange = "#ffaf00",

	gray0 = "#121212",
	gray1 = "#262626",
	gray2 = "#303030",
	gray3 = "#4e4e4e",
	gray4 = "#585858",
	gray5 = "#606060",
	gray6 = "#808080",
	gray7 = "#8a8a8a",
	gray8 = "#9e9e9e",
	gray9 = "#bcbcbc",
	gray10 = "#d0d0d0",

	yellow = "#b58900",
	orange = "#cb4b16",
	red = "#dc322f",
	magenta = "#d33682",
	violet = "#6c71c4",
	blue = "#268bd2",
	cyan = "#2aa198",
	green = "#859900",
}

local powerline = {
	normal = {
		a = { fg = Colors.darkestgreen, bg = Colors.brightgreen, gui = "bold" },
		b = { fg = Colors.white, bg = Colors.gray4 },
		c = { fg = Colors.gray7, bg = Colors.gray2 },
		x = { fg = Colors.gray7, bg = Colors.gray2 },
		y = { fg = Colors.gray9, bg = Colors.gray4 },
		z = { fg = Colors.gray5, bg = Colors.gray10 },
	},
	insert = {
		a = { fg = Colors.darkestcyan, bg = Colors.white, gui = "bold" },
		b = { fg = Colors.white, bg = Colors.darkblue },
		c = { fg = Colors.mediumcyan, bg = Colors.darkestblue },
		x = { fg = Colors.mediumcyan, bg = Colors.darkestblue },
		y = { fg = Colors.mediumcyan, bg = Colors.darkblue },
		z = { fg = Colors.darkestcyan, bg = Colors.mediumcyan },
	},
	visual = {
		a = { fg = Colors.darkred, bg = Colors.brightorange, gui = "bold" },
		z = { fg = Colors.gray5, bg = Colors.gray10 },
	},
	replace = {
		a = { fg = Colors.white, bg = Colors.brightred, gui = "bold" },
		z = { fg = Colors.gray5, bg = Colors.gray10 },
	},
	inactive = {
		a = { fg = Colors.gray1, bg = Colors.gray5 },
		b = { fg = Colors.gray4, bg = Colors.gray5 },
		c = { bg = Colors.gray4, fg = Colors.gray0 },
	},
	tabline,
}

function show_lsp()
	-- From https://gist.github.com/l00sed/8cadeb747d24dea37f3e279ce18d8472
	local msg = "No LSP"
	local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
	local clients = vim.lsp.get_active_clients()

	if next(clients) == nil then
		return msg
	end

	for _, client in ipairs(clients) do
		local filetypes = client.config.filetypes

		if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
			return "⚙ " .. client.name
		end
	end

	return msg
end

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		},
	},
	sections = {
		lualine_a = { "mode", "paste" },
		lualine_b = {
			"branch",
			"diff",
			{
				"diagnostics",
				sources = { "nvim_diagnostic", "nvim_lsp" },
			},
		},
		lualine_c = {
			{
				"filename",
				file_status = true,
				newfile_status = true,
				path = 1, -- 0: Just the filename
				-- 1: Relative path
				-- 2: Absolute path
				-- 3: Absolute path, with tilde as the home directory
				-- 4: Filename and parent dir, with tilde as the home directory
				symbols = {
					modified = "[+]",
					readonly = "",
					unnamed = "[No Name]",
					newfile = "[Nesw]",
				},
			},
			"selectioncount",
			"searchcount",
		},
		lualine_x = { "encoding", "fileformat", show_lsp, "filetype" },
		lualine_y = { "progress" },
		lualine_z = { {
			"location",
			fmt = function(str)
				return "" .. str
			end,
		} },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {
		lualine_a = {},
		lualine_b = {
			{
				"tabs",
				show_filename_only = true, -- Shows shortened relative path when set to false.
				hide_filename_extension = false, -- Hide filename extension when set to true.
				show_modified_status = true, -- Shows indicator when the tab is modified.

				mode = 2, -- 0: Shows tab name
				-- 1: Shows tab index
				-- 2: Shows tab name + tab index
				-- 3: Shows tab number
				-- 4: Shows tab name + tab number

				max_length = vim.o.columns * 2 / 3, -- Maximum width of tabs component,
				-- it can also be a function that returns
				-- the value of `max_length` dynamically.
				filetype_names = {
					TelescopePrompt = "Telescope",
					dashboard = "Dashboard",
					packer = "Packer",
					fzf = "FZF",
					alpha = "Alpha",
				}, -- Shows specific tab name for that filetype ( { `filetype` = `tab_name`, ... } )

				-- Automatically updates active tab color to match color of other components (will be overidden if tabs_color is set)
				use_mode_colors = true,

				symbols = {
					modified = " ●", -- Text to show when the tab is modified
					alternate_file = "#", -- Text to show to identify the alternate file
					directory = "", -- Text to show when the tab is a directory
				},
			},
		},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_winbar = {},
	extensions = { "trouble", "mason", "fugitive", "quickfix" },
})

vim.opt.laststatus = 2
vim.opt.showmode = false
