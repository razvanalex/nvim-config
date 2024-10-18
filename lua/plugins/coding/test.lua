return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",

			-- Test Adapters
			"nvim-neotest/neotest-python",
			"fredrikaverpil/neotest-golang",
		},
		cmd = "Neotest",
		cond = not vim.g.vscode,
		config = function()
			local neotest = require("neotest")
			---@diagnostic disable-next-line: missing-fields
			neotest.setup({
				adapters = {
					require("neotest-python")({
						dap = { justMyCode = false },
					}),
					require("neotest-golang"),
				},
			})
		end,
		keys = {
			{
				"<leader>Tr",
				function()
					require("neotest").run.run()
				end,
				desc = "[T]est [R]un Nearest",
			},
			{
				"<leader>Tf",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "[Test] Run [F]ile",
			},
			{
				"<leader>Ta",
				function()
					require("neotest").run.run(vim.fn.expand(vim.fn.getcwd()))
				end,
				desc = "[Test] Run [A]ll CWD",
			},
			{
				"<leader>Td",
				function()
					---@diagnostic disable-next-line: missing-fields
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "[Test] Run Nearest [D]ebug",
			},
			{
				"<leader>Ts",
				function()
					require("neotest").run.stop()
				end,
				desc = "[Test] [S]top Nearest",
			},
			{
				"<leader>Ta",
				function()
					require("neotest").run.stop()
				end,
				desc = "[Test] [A]ttach Nearest",
			},
			{ "<leader>TS", ":Neotest summary<CR>", desc = "[Test] [S]ummary" },
			{ "<leader>To", ":Neotest output<CR>", desc = "[Test] [O]utput Window" },
			{ "<leader>TO", ":Neotest output-panel<CR>", desc = "[Test] [O]utput Panel" },
		},
	},
}
