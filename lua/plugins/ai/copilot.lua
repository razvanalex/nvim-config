return {
	{
		"zbirenbaum/copilot.lua",
		dependencies = {
			"copilotlsp-nvim/copilot-lsp",
			init = function()
				vim.g.copilot_nes_debounce = 500
			end,
		},
		cmd = "Copilot",
		event = "InsertEnter",
		enabled = not vim.g.vscode,
		opts = {
			nes = {
				enabled = true,
				auto_trigger = true,
				keymap = {
					accept_and_goto = "<Tab>",
					accept = "<S-Tab",
					dismiss = "<Esc>",
				},
			},
			suggestion = {
				enabled = true,
				auto_trigger = true,
				hide_during_completion = false,
				debounce = 75,
				keymap = {
					accept = "<M-Y>",
					accept_word = false,
					accept_line = "<M-y>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
		},
	},
}
