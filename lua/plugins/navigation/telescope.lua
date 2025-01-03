return {
	{ -- fuzzy finder
		"nvim-telescope/telescope.nvim",
		lazy = true,
		cond = not vim.g.vscode,
		cmd = "Telescope",
		branch = "master", -- stable: 0.1.x
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for install instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = "make",

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
			{ "nvim-telescope/telescope-media-files.nvim" }, -- FIXME: not working

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			-- Telescope is a fuzzy finder that comes with a lot of different things that
			-- it can fuzzy find! It's more than just a "file finder", it can search
			-- many different aspects of Neovim, your workspace, LSP, and more!
			--
			-- The easiest way to use telescope, is to start by doing something like:
			--  :Telescope help_tags
			--
			-- After running this command, a window will open up and you're able to
			-- type in the prompt window. You'll see a list of help_tags options and
			-- a corresponding preview of the help.
			--
			-- Two important keymaps to use while in telescope are:
			--  - Insert mode: <c-/>
			--  - Normal mode: ?
			--
			-- This opens a window that shows you all of the keymaps for the current
			-- telescope picker. This is really useful to discover what Telescope can
			-- do as well as how to actually do it!

			-- [[ Configure Telescope ]]
			-- See `:help telescope` and `:help telescope.setup()`
			local telescope = require("telescope")
			local lga_actions = require("telescope-live-grep-args.actions")

			telescope.setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
					media_files = {
						filetypes = { "png", "webp", "mp4", "jpg", "jpeg", "pdf" },
						find_cmd = "rg",
					},
					live_grep_args = {
						auto_quoting = true, -- enable/disable auto-quoting
						-- define mappings, e.g.
						mappings = { -- extend mappings
							i = {
								["<C-k>"] = lga_actions.quote_prompt(),
								["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
								-- freeze the current list and start a fuzzy search in the frozen list
								["<C-space>"] = require("telescope.actions").to_fuzzy_refine,
							},
						},
						-- ... also accepts theme settings, for example:
						-- theme = "dropdown", -- use dropdown theme
						-- theme = { }, -- use own theme spec
						-- layout_config = { mirror=true }, -- mirror preview pane
					},
				},
			})

			-- Enable telescope extensions, if they are installed
			pcall(telescope.load_extension, "fzf")
			pcall(telescope.load_extension, "ui-select")
			pcall(telescope.load_extension, "media_files")
			pcall(telescope.load_extension, "live_grep_args")

			local C = require("catppuccin.palettes").get_palette()
			local TelescopeColor = {
				TelescopeBorder = { fg = C.mantle, bg = C.mantle },
				TelescopeMatching = { fg = C.blue },
				TelescopeNormal = { bg = C.mantle },
				TelescopePromptBorder = { fg = C.surface0, bg = C.surface0 },
				TelescopePromptNormal = { fg = C.text, bg = C.surface0 },
				TelescopePromptPrefix = { fg = C.flamingo, bg = C.surface0 },
				TelescopePreviewTitle = { fg = C.base, bg = C.green },
				TelescopePromptTitle = { fg = C.base, bg = C.red },
				TelescopeResultsTitle = { fg = C.mantle, bg = C.lavender },
				TelescopeSelection = { fg = C.text, bg = C.surface0 },
				TelescopeSelectionCaret = { fg = C.flamingo },
			}

			for hl, col in pairs(TelescopeColor) do
				vim.api.nvim_set_hl(0, hl, col)
			end
		end,
		keys = {
			{
				"<leader>fh",
				function()
					require("telescope.builtin").help_tags()
				end,
				mode = "n",
				desc = "[F]uzzy [H]elp Tags",
			},
			{
				"<leader>ff",
				function()
					local builtin = require("telescope.builtin")
					builtin.find_files()
				end,
				mode = "n",
				desc = "[F]uzzy File [F]inder",
			},
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers()
				end,
				mode = "n",
				desc = "[F]uzzy [B]uffers",
			},
			{
				"<leader>fg",
				function()
					require("telescope").extensions.live_grep_args.live_grep_args()
				end,
				mode = "n",
				desc = "[F]uzzy [G]rep Files",
			},
			{
				"<leader>fG",
				function()
					require("telescope").extensions.live_grep_args.live_grep_args({
						additional_args = { "--hidden", "--no-ignore" },
						prompt_title = "Live Grep All (Args)",
						previewer = false,
					})
				end,
				mode = "n",
				desc = "[F]uzzy [G]rep All Files",
			},
			{
				"<leader>fv",
				function()
					require("telescope.builtin").git_files()
				end,
				mode = "n",
				desc = '[F]uzzy Git Files ("v" for versioning)',
			},
			{
				"<leader>fS",
				function()
					require("telescope.builtin").builtin()
				end,
				mode = "n",
				desc = "[F]uzzy [S]elect Telescope",
			},
			{
				"<leader>fw",
				function()
					require("telescope.builtin").grep_string()
				end,
				mode = "n",
				desc = "[F]uzzy Current [W]ord",
			},
			{
				"<leader>fW",
				function()
					require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
				end,
				mode = "n",
				desc = "[F]uzzy [W]ord",
			},
			{
				"<leader>fs",
				function()
					require("telescope.builtin").lsp_dynamic_workspace_symbols()
				end,
				mode = "n",
				desc = "[F]uzzy Dynamic Workspace [S]ymbol",
			},
			{
				"<leader>fd",
				function()
					require("telescope.builtin").diagnostics()
				end,
				mode = "n",
				desc = "[F]uzzy [D]iagnostics",
			},
			{
				"<leader>fr",
				function()
					require("telescope.builtin").resume()
				end,
				mode = "n",
				desc = "[F]uzzy [R]esume",
			},
			{
				"<leader>f.",
				function()
					require("telescope.builtin").oldfiles()
				end,
				mode = "n",
				desc = '[F]uzzy Recent Files ("." for repeat)',
			},
			{
				"<leader>fk",
				function()
					require("telescope.builtin").keymaps()
				end,
				mode = "n",
				desc = "[F]uzzy [K]eymaps",
			},
			{
				"<leader>fa",
				function()
					require("telescope.builtin").find_files({
						find_command = { "rg", "--files", "--hidden", "--no-ignore-vcs" },
						prompt_title = "Find All",
					})
				end,
				mode = "n",
				desc = "[F]uzzy Find [A]ll Files",
			},
			{
				"<leader>f/",
				function()
					require("telescope.builtin").live_grep({
						en_files = true,
						prompt_title = "Live Grep in Open Files",
					})
				end,
				mode = "n",
				desc = "[F]uzzy [/] in Open Files",
			},
			{
				"<leader>fn",
				function()
					require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
				end,
				mode = "n",
				desc = "[F]uzzy [N]eovim files",
			},
		},
	},
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cond = not vim.g.vscode,
		lazy = true,
		cmd = { "FzfLua" },
		opts = {},
	},
}
