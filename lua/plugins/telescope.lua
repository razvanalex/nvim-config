return {
	"nvim-telescope/telescope-media-files.nvim",
	{ -- fuzzy finder
		"nvim-telescope/telescope.nvim",
		cond = not vim.g.vscode,
		event = "VimEnter",
		branch = "0.1.x",
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
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
					media_files = {
						filetypes = { "png", "webp", "mp4", "jpg", "jpeg", "pdf" },
						find_cmd = "rg",
					},
				},
			})

			-- Enable telescope extensions, if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
			pcall(require("telescope").load_extension, "media_files")

			-- See `:help telescope.builtin`
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]uzzy [H]elp Tags" })
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]uzzy File [F]inder" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]uzzy File [G]rep" })
			vim.keymap.set("n", "<leader>fv", builtin.git_files, { desc = '[F]uzzy Git Files ("v" for versioning)' })
			vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[F]uzzy [S]elect Telescope" })
			vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]uzzy Current [W]ord" })
			vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]uzzy [D]iagnostics" })
			vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]uzzy [R]esume" })
			vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]uzzy Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]uzzy [K]eymaps" })
			vim.keymap.set("n", "<leader>fa", function()
				builtin.find_files({
					find_command = { "rg", "--files", "--hidden", "--no-ignore-vcs" },
				})
			end, { desc = "[F]uzzy Find [A]ll Files" })

			vim.keymap.set("n", "<leader>f/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[F]uzzy [/] in Open Files" })

			vim.keymap.set("n", "<leader>fn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[F]uzzy [N]eovim files" })

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
	},
}
