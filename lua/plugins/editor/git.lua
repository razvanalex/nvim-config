return {
	{ -- git commands inside vim (e.g., diff, commit, mergetool, blame)
		"tpope/vim-fugitive",
		cond = not vim.g.vscode,
		lazy = true,
		dependencies = {
			"tpope/vim-rhubarb",
		},
		cmd = {
			"Git",
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
		cond = not vim.g.vscode,
		dependencies = {
			"tpope/vim-fugitive",
		},
		lazy = true,
		cmd = "GBrowse",
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = "VeryLazy",
		cond = not vim.g.vscode,
		opts = {
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
			current_line_blame_opts = {
				delay = 500,
			},
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
			preview_config = {
				border = "single",
			},
			on_attach = function(bufnr)
				if vim.bo[bufnr].filetype == "netrw" then
					return false
				end

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
		},
	},
	{
		"pwntester/octo.nvim",
		lazy = true,
		cond = not vim.g.vscode,
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
		cond = not vim.g.vscode,
		branch = "main",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		opts = {},
		lazy = true,
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
