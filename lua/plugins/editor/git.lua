return {
	{ -- git commands inside vim (e.g., diff, commit, mergetool, blame)
		"tpope/vim-fugitive",
		lazy = true,
		cmd = {
			"Git",
			"GBrowse",
			"Gedit",
			"Gsplit",
			"Gdiffsplit",
			"Gvdiffsplit",
			"Gread",
			"Gwrite",
			"Ggrep",
			"GMove",
			"GRename",
			"GDelete",
			"GUnlink",
			"Glgrep",
			"Gclog",
			"Gllog",
			"Gcd",
			"Glcd",
			"Gvsplit",
			"Gtabedit",
			"Gpedit",
			"Gdrop",
			"Gwq",
		},
		keys = {
			{ "<leader>gg", vim.cmd.Git, desc = "[G]it Sta[g]e Area" },
		},
	},
	{ -- enable :GBrowse to open current repo in GitHub
		"tpope/vim-rhubarb",
		lazy = true,
		cmd = "GBrowse",
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		cond = not vim.g.vscode,
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "┃" },
					change = { text = "┃" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
				signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
				numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
				linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
				word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
				watch_gitdir = {
					follow_files = true,
				},
				auto_attach = true,
				attach_to_untracked = false,
				current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
					delay = 500,
					ignore_whitespace = false,
					virt_text_priority = 100,
				},
				current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
				sign_priority = 6,
				update_debounce = 100,
				status_formatter = nil, -- Use default
				max_file_length = 40000, -- Disable if file is longer than this (in lines)
				preview_config = {
					-- Options passed to nvim_open_win
					border = "single",
					style = "minimal",
					relative = "cursor",
					row = 0,
					col = 1,
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							return "]c"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Next Git Hunk" })

					map("n", "[c", function()
						if vim.wo.diff then
							return "[c"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true, desc = "Prev Git Hunk" })

					-- Actions
					map("n", "<leader>gs", gs.stage_hunk, { desc = "[G]it Hunk [S]tage" })
					map("n", "<leader>gr", gs.reset_hunk, { desc = "[G]it Hunk [R]eset" })
					map("v", "<leader>gs", function()
						gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "[G]it Hunk [S]tage" })
					map("v", "<leader>gr", function()
						gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "[G]it Hunk [R]eset" })
					map("n", "<leader>gS", gs.stage_buffer, { desc = "[G]it Hunk [S]tage Buffer" })
					map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "[G]it Hunk [U]ndo Stage" })
					map("n", "<leader>gR", gs.reset_buffer, { desc = "[G]it [R]eset Buffer" })
					map("n", "<leader>gp", gs.preview_hunk, { desc = "[G]it [P]review Hunk" })
					map("n", "<leader>gb", function()
						gs.blame_line({ full = true })
					end, { desc = "[G]it Hunk [B]lame" })
					map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "[G]it [T]oggle Line [B]lame" })
					map("n", "<leader>gd", gs.diffthis, { desc = "[G]it [D]iff This" })
					map("n", "<leader>gD", function()
						gs.diffthis("~")
					end, { desc = "[G]it [D]iff This" })
					map("n", "<leader>gtd", gs.toggle_deleted, { desc = "[G]it [T]oggle [D]eleted" })

					-- Text object
					map({ "o", "x" }, "gh", ":<C-U>Gitsigns select_hunk<CR>", { desc = "[G]it Select [H]unk" })
				end,
			})
		end,
	},
	{
		"pwntester/octo.nvim",
		cmd = {
			"Octo",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
	},
	{
		"polarmutex/git-worktree.nvim",
		branch = "main",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		opts = {},
		lazy = false,
		config = function()
			require("telescope").load_extension("git_worktree")

			local hooks = require("git-worktree.hooks")

			hooks.register(hooks.type.SWITCH, hooks.builtins.update_current_buffer_on_switch)
		end,
		keys = {
			{
				"<leader>gww",
				function()
					require("telescope").extensions.git_worktree.git_worktree()
				end,
				desc = "[G]it [W]orktrees [W]indow",
			},
			{
				"<leader>gwc",
				function()
					require("telescope").extensions.git_worktree.create_git_worktree()
				end,
				desc = "[G]it [W]orktrees [C]reate",
			},
		},
	},
}
