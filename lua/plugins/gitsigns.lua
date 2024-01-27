require("gitsigns").setup({
	signs = {
		add = { text = "│" },
		change = { text = "│" },
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
		delay = 1000,
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
	yadm = {
		enable = false,
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
		map("n", "<leader>gs", gs.stage_hunk, { desc = "Git Hunk Stage" })
		map("n", "<leader>gr", gs.reset_hunk, { desc = "Git Hunk Reset" })
		map("v", "<leader>gs", function()
			gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Git Hunk Stage" })
		map("v", "<leader>gr", function()
			gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "Git Hunk Reset" })
		map("n", "<leader>gS", gs.stage_buffer, { desc = "Git Hunk Stage Buffer" })
		map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Git Hunk Undo Stage" })
		map("n", "<leader>gR", gs.reset_buffer, { desc = "Git Reset Buffer" })
		map("n", "<leader>gp", gs.preview_hunk, { desc = "Git Preview Hunk" })
		map("n", "<leader>gb", function()
			gs.blame_line({ full = true })
		end, { desc = "Git Hunk Blame" })
		map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "Git Toggle Line Blame" })
		map("n", "<leader>gd", gs.diffthis, { desc = "Git Diff This" })
		map("n", "<leader>gD", function()
			gs.diffthis("~")
		end, { desc = "Git Diff This" })
		map("n", "<leader>gtd", gs.toggle_deleted, { desc = "Git Toggle Deleted" })

		-- Text object
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Git Select Hunk" })
	end,
})
