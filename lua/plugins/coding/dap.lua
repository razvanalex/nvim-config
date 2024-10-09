return {
	{ -- DAP interface for nvim
		"mfussenegger/nvim-dap",
		cond = not vim.g.vscode,
		cmd = {
			"DapContinue",
			"DapLoadLaunchJSON",
			"DapRestartFrame",
			"DapSetLogLevel",
			"DapShowLog",
			"DapStepInto",
			"DapStepOut",
			"DapStepOver",
			"DapTerminate",
			"DapToggleBreakpoint",
			"DapToggleRepl",
		},
		lazy = true,
		config = function()
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

			-- set dap ui
			local dap, dapui = require("dap"), require("dapui")

			---@diagnostic disable-next-line: missing-fields
			dapui.setup({
				expand_lines = false,
			})

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
		keys = {
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				mode = "n",
				desc = "Debug Launch",
			},
			{
				"<F6>",
				function()
					require("dap").close()
				end,
				mode = "n",
				desc = "Stop",
			},
			{
				"<F7>",
				function()
					require("dap").restart()
				end,
				mode = "n",
				desc = "Restart",
			},
			{
				"<F8>",
				function()
					require("dap").disconnect()
				end,
				mode = "n",
				desc = "Disconnect",
			},
			{
				"<F9>",
				function()
					require("dap").step_back()
				end,
				mode = "n",
				desc = "Step Back",
			},
			{
				"<F10>",
				function()
					require("dap").step_over()
				end,
				mode = "n",
				desc = "Step Over",
			},
			{
				"<F11>",
				function()
					require("dap").step_into()
				end,
				mode = "n",
				desc = "Step In",
			},
			{
				"<F12>",
				function()
					require("dap").step_out()
				end,
				mode = "n",
				desc = "Step Out",
			},
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				mode = "n",
				desc = "[D]ebugger Toggle [B]reakpoint",
			},
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint()
				end,
				mode = "n",
				desc = "[D]ebugger Set [B]reakpoint",
			},
			{
				"<leader>dlp",
				function()
					require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
				end,
				mode = "n",
				desc = "[D]ebugger Set [L]og [P]oint",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				mode = "n",
				desc = "[D]ebugger Open [R]EPL",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				mode = "n",
				desc = "[D]ebugger Run [L]ast",
			},
			{
				"<leader>dh",
				function()
					require("dap.ui.widgets").hover()
				end,
				mode = { "n", "v" },
				desc = "[D]ebugger [H]over Widget",
			},
			{
				"<leader>dp",
				function()
					require("dap.ui.widgets").preview()
				end,
				mode = { "n", "v" },
				desc = "[D]ebugger [P]review Widget",
			},
			{
				"<leader>dff",
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.frames)
				end,
				mode = "n",
				desc = "[D]ebugger [F]loat [F]rames",
			},
			{
				"<leader>dfu",
				function()
					require("dap").up()
				end,
				mode = "n",
				desc = "[D]ebugger [F]rames [U]p",
			},
			{
				"<leader>dfd",
				function()
					require("dap").down()
				end,
				mode = "n",
				desc = "[D]ebugger [F]rames [D]own",
			},
			{
				"<leader>dfs",
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.scopes)
				end,
				mode = "n",
				desc = "[D]ebugger [F]loat [S]copes",
			},
		},
	},
	{ -- UI for DAP
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		lazy = true,
		cond = not vim.g.vscode,
		keys = {
			{
				"<leader>dd",
				function()
					require("dapui").open()
				end,
				desc = "[D]ebugger Open [D]AP mode",
			},
			{
				"<leader>dc",
				function()
					require("dapui").close()
				end,
				desc = "[D]ebugger [C]lose DAP mode",
			},
		},
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
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		lazy = true,
		ft = "python",
		cond = not vim.g.vscode,
		opts = {},
		config = function()
			if os.execute("[ -d ~/.virtualenvs/debugpy ]") ~= 0 then
				local ret = os.execute("mkdir -p ~/.virtualenvs && \
						cd ~/.virtualenvs && \
						python3 -m venv debugpy && \
						debugpy/bin/python -m pip install debugpy")
				if ret ~= 0 then
					vim.notify("Failed to install debugpy in ~/.virtualenvs/debugpy")
				else
					vim.notify("Successfully installed debyugpy in ~/.virtualenvs/debugpy")
				end
			end

			require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
		end,
	},
	{ -- Go DAP
		"leoluz/nvim-dap-go",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		lazy = true,
		ft = "go",
		cond = not vim.g.vscode,
		opts = {},
	},
}
