return { -- shows issues in code (like Problems in vscode)
	"folke/trouble.nvim",
	lazy = true,
	cond = not vim.g.vscode,
	cmd = "Trouble",
	dependencies = {
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	opts = {
		use_diagnostic_signs = true,
	},
	keys = {
		{
			"<leader>tt",
			function()
				local trouble = require("trouble")
				if trouble.last_mode == nil then
					require("trouble").toggle("diagnostics")
				else
					require("trouble").toggle(trouble.last_mode)
				end
			end,
			desc = "[T]rouble [T]oggle",
		},
		{
			"<leader>td",
			function()
				require("trouble").toggle("diagnostics")
			end,
			desc = "[T]rouble [D]iagnostics",
		},
		{
			"<leader>tq",
			function()
				require("trouble").toggle("quickfix")
			end,
			desc = "[T]rouble [Q]uickfix",
		},
		{
			"<leader>tL",
			function()
				require("trouble").toggle("loclist")
			end,
			desc = "[T]rouble [L]oclist",
		},
		{
			"<leader>tlD",
			function()
				require("trouble").toggle("lsp_declarations")
			end,
			desc = "[T]rouble [L]SP [D]eclarations",
		},
		{
			"<leader>tld",
			function()
				require("trouble").toggle("lsp_definitions")
			end,
			desc = "[T]rouble [L]SP [D]efinitions",
		},
		{
			"<leader>tls",
			function()
				require("trouble").toggle("lsp_document_symbols")
			end,
			desc = "[T]rouble [L]SP Document [S]ymbols",
		},
		{
			"<leader>tlI",
			function()
				require("trouble").toggle("lsp_implementations")
			end,
			desc = "[T]rouble [L]SP [I]mplementations",
		},
		{
			"<leader>tli",
			function()
				require("trouble").toggle("lsp_incoming_calls")
			end,
			desc = "[T]rouble [L]SP [I]ncomming Calls",
		},
		{
			"<leader>tlo",
			function()
				require("trouble").toggle("lsp_outgoing_calls")
			end,
			desc = "[T]rouble [L]SP [O]utgoing Calls",
		},
		{
			"<leader>tlr",
			function()
				require("trouble").toggle("lsp_references")
			end,
			desc = "[T]rouble [L]SP [R]references",
		},
		{
			"<leader>tlt",
			function()
				require("trouble").toggle("lsp_type_definitions")
			end,
			desc = "[T]rouble [L]SP [T]ype Definitions",
		},
		{
			"]t",
			function()
				require("trouble").next({ skip_groups = true, jump = true })
			end,
			desc = "[T]rouble Next",
		},
		{
			"[t",
			function()
				require("trouble").prev({ skip_groups = true, jump = true })
			end,
			desc = "[T]rouble Previous",
		},
	},
}
