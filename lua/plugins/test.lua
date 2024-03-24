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
			"nvim-neotest/neotest-go",
		},
		cond = not vim.g.vscode,
		config = function()
			local neotest = require("neotest")
			---@diagnostic disable-next-line: missing-fields
			neotest.setup({
				adapters = {
					require("neotest-python")({
						dap = { justMyCode = false },
					}),
					require("neotest-go"),
				},
			})

			vim.keymap.set("n", "<leader>Tr", function()
				neotest.run.run()
			end, { desc = "[T]est [R]un Nearest" })

			vim.keymap.set("n", "<leader>Tf", function()
				neotest.run.run(vim.fn.expand("%"))
			end, { desc = "[Test] Run [F]ile" })

			vim.keymap.set("n", "<leader>Ta", function()
				neotest.run.run(vim.fn.expand(vim.fn.getcwd()))
			end, { desc = "[Test] Run [A]ll CWD" })

			vim.keymap.set("n", "<leader>Td", function()
				---@diagnostic disable-next-line: missing-fields
				require("neotest").run.run({ strategy = "dap" })
			end, { desc = "[Test] Run Nearest [D]ebug" })

			vim.keymap.set("n", "<leader>Ts", function()
				require("neotest").run.stop()
			end, { desc = "[Test] [S]top Nearest" })

			vim.keymap.set("n", "<leader>Ta", function()
				require("neotest").run.stop()
			end, { desc = "[Test] [A]ttach Nearest" })

			vim.keymap.set("n", "<leader>TS", ":Neotest summary<CR>", { desc = "[Test] [S]ummary" })
			vim.keymap.set("n", "<leader>To", ":Neotest output<CR>", { desc = "[Test] [O]utput Window" })
			vim.keymap.set("n", "<leader>TO", ":Neotest output-panel<CR>", { desc = "[Test] [O]utput Panel" })
		end,
	},
}
