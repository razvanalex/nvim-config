return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			-- key mappings
			vim.keymap.set("n", "<F5>", function()
				require("dap").continue()
			end, { desc = "Debug Launch" })

			vim.keymap.set("n", "<F10>", function()
				require("dap").step_over()
			end, { desc = "Step Over" })

			vim.keymap.set("n", "<F11>", function()
				require("dap").step_into()
			end, { desc = "Step In" })

			vim.keymap.set("n", "<F12>", function()
				require("dap").step_out()
			end, { desc = "Step Out" })

			vim.keymap.set("n", "<Leader>b", function()
				require("dap").toggle_breakpoint()
			end, { desc = "Toggle Breakpoint" })

			vim.keymap.set("n", "<Leader>B", function()
				require("dap").set_breakpoint()
			end, { desc = "Set Breakpoint" })

			vim.keymap.set("n", "<Leader>lp", function()
				require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end, { desc = "Set Log Point" })

			vim.keymap.set("n", "<Leader>dr", function()
				require("dap").repl.open()
			end, { desc = "Open REPL" })

			vim.keymap.set("n", "<Leader>dl", function()
				require("dap").run_last()
			end, { desc = "Run Last" })

			vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
				require("dap.ui.widgets").hover()
			end, { desc = "Hover Widget" })

			vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
				require("dap.ui.widgets").preview()
			end, { desc = "Preview Widget" })

			vim.keymap.set("n", "<Leader>df", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end, { desc = "Centered Float Widget" })

			vim.keymap.set("n", "<Leader>ds", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end, { desc = "Centered Float Scopes" })

			-- Nicer icons. From docs:
			--  - DapBreakpoint for breakpoints (default: B)
			--  - DapBreakpointCondition for conditional breakpoints (default: C)
			--  - DapLogPoint for log points (default: L)
			--  - DapStopped to indicate where the debugee is stopped (default: →)
			--  - DapBreakpointRejected to indicate breakpoints rejected by the debug adapter (default: R)
			--
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define(
				"DapBreakpointRejected",
				{ text = "", texthl = "DiagnosticError", linehl = "", numhl = "" }
			)
			vim.fn.sign_define(
				"DapStopped",
				{ text = "→", texthl = "DiagnosticOk", linehl = "DapStopped", numhl = "" }
			)
			vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo", linehl = "", numhl = "" })

			-- Set highlight
			vim.api.nvim_set_hl(0, "DapStopped", { bg = "#494a10" })
		end,
	}, -- DAP interface for nvim
	{ -- UI for DAP
		"rcarriga/nvim-dap-ui",
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			dapui.setup({
				expand_lines = false,
			})

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
	{
		-- Setup Python DAP with default debugpy environment, created with:
		--
		-- mkdir .virtualenvs
		-- cd .virtualenvs
		-- python -m venv debugpy
		-- debugpy/bin/python -m pip install debugpy
		--
		"mfussenegger/nvim-dap-python",
		config = function()
			require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
		end,
	},
	{ "leoluz/nvim-dap-go", opts = {} }, -- Go DAP
}
