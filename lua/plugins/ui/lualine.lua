--- Get the activate virtual environment via venv or conda. Shows only if the file is python.
local function virtual_env()
	-- source: https://www.reddit.com/r/neovim/comments/16ya0fr/show_the_current_python_virtual_env_on_statusline/
	-- only show virtual env for Python
	if vim.bo.filetype ~= "python" then
		return ""
	end

	local venv_path = os.getenv("VIRTUAL_ENV")
	if venv_path ~= nil then
		local venv_name = vim.fn.fnamemodify(venv_path, ":t")
		return string.format("(venv) %s", venv_name)
	end

	local conda_env = os.getenv("CONDA_DEFAULT_ENV")
	if conda_env ~= nil then
		return string.format("(conda) %s", conda_env)
	end
end

local function get_venv()
	-- determine environment from env vars
	local env = virtual_env()
	if env ~= nil then
		return env
	end

	-- determine the environment from venv-selector
	-- FIXME: not tested on other than venv and conda
	local active_venv_path = require("venv-selector").get_active_venv()
	if active_venv_path ~= nil then
		local dirs = {}
		for k, _ in string.gmatch(active_venv_path, "[^/]+") do
			table.insert(dirs, k)
		end
		if #dirs > 2 then
			return dirs[#dirs - 1]
		end
		return dirs[#dirs]
	end

	return ""
end

local function show_lsp()
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
			local client_name = client.name
			return " " .. client_name
		end
	end

	return msg
end

return {
	"nvim-lualine/lualine.nvim",
	cond = not vim.g.vscode,
	opts = {
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
			globalstatus = true,
			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000,
			},
		},
		sections = {
			lualine_a = { "mode", "paste" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = {
				{
					"filename",
					file_status = true,
					newfile_status = true,
					path = 1,
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
			lualine_x = {
				{
					require("lazy.status").updates,
					cond = require("lazy.status").has_updates,
					color = { fg = "#ff9e64" },
				},
				"encoding",
				"fileformat",
				show_lsp,
				get_venv,
				"filetype",
			},
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
		extensions = {
			"trouble",
			"mason",
			"fugitive",
			"quickfix",
			"lazy",
			"nvim-tree",
			"nvim-dap-ui",
			"symbols-outline",
		},
	},
}
