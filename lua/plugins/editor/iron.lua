return {
	"Vigemus/iron.nvim",
	event = "VeryLazy",
	lazy = true,
	cmd = {
		"IronRepl",
		"IronReplHere",
		"IronRestart",
		"IronSend",
		"IronFocus",
		"IronHide",
		"IronWatch",
		"IronAttach",
	},
	keys = {
		{ "<space>Rr", "<cmd>IronRepl<cr>", desc = "Open REPL" },
		{ "<space>Rh", "<cmd>IronReplHere<cr>", desc = "Open REPL here" },
		{ "<space>RR", "<cmd>IronRestart<cr>", desc = "Restart REPL" },
		{ "<space>Rf", "<cmd>IronFocus<cr>", desc = "Focus REPL" },
		{ "<space>Ri", "<cmd>IronHide<cr>", desc = "Hide REPL" },
	},
	opts = function()
		local common = require("iron.fts.common")
		local view = require("iron.view")

		return {
			config = {
				scratch_repl = true,
				repl_definition = {
					sh = {
						command = { "zsh" },
					},
					python = {
						command = { "ipython", "--no-autoindent" },
						format = common.bracketed_paste,
						block_dividers = { "# %%", "#%%" },
						env = { PYTHON_BASIC_REPL = "1" },
					},
				},
				repl_filetype = function(bufnr, ft)
					return ft
				end,
				dap_integration = true,
				repl_open_cmd = view.split.vertical.botright(0.4),
			},
			keymaps = {
				send_motion = "<space>Rsc",
				visual_send = "<space>Rsc",
				send_file = "<space>Rsf",
				send_line = "<space>Rsl",
				send_until_cursor = "<space>Rsu",
				send_mark = "<space>Rsm",
				send_code_block = "<space>Rsb",
				send_code_block_and_move = "<space>Rsn",
				mark_motion = "<space>Rmc",
				mark_visual = "<space>Rmc",
				remove_mark = "<space>Rmd",
				cr = "<space>Rs<cr>",
				interrupt = "<space>Rs<space>",
				exit = "<space>Rsq",
				clear = "<space>Rcl",
			},
			highlight = {
				italic = true,
			},
			ignore_blank_lines = true,
		}
	end,
}
