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
			-- Set highlight
			vim.api.nvim_set_hl(0, "DapStopped", { bg = "#494a10" })

			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "C" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "DapStopped" })
			vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo" })

			-- set dap ui
			local dapui = require("dapui")

			---@diagnostic disable-next-line: missing-fields
			dapui.setup({
				expand_lines = false,
			})
		end,
		keys = {
			{
				"<leader>drl",
				function()
					require("dap").continue()
				end,
				mode = "n",
				desc = "[D]ebugger [R]un [L]aunch",
			},
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				mode = "n",
				desc = "[D]ebugger [R]un [L]aunch",
			},
			{
				"<leader>drL",
				function()
					require("dap").run_last()
				end,
				mode = "n",
				desc = "[D]ebugger [R]un [L]ast",
			},
			{
				"<leader>drs",
				function()
					require("dap").close()
				end,
				mode = "n",
				desc = "[D]ebugger [R]un [S]top",
			},
			{
				"<F6>",
				function()
					require("dap").close()
				end,
				mode = "n",
				desc = "[D]ebugger [R]un [S]top",
			},
			{
				"<leader>drr",
				function()
					require("dap").restart()
				end,
				mode = "n",
				desc = "[D]ebugger [R]un [R]estart",
			},
			{
				"<F7>",
				function()
					require("dap").restart()
				end,
				mode = "n",
				desc = "[D]ebugger [R]un [R]estart",
			},
			{
				"<leader>drd",
				function()
					require("dap").disconnect()
				end,
				mode = "n",
				desc = "[D]ebugger [R]un [D]isconnect",
			},
			{
				"<F8>",
				function()
					require("dap").disconnect()
				end,
				mode = "n",
				desc = "[D]ebugger [R]un [D]isconnect",
			},
			{
				"<leader>dsb",
				function()
					require("dap").step_back()
				end,
				mode = "n",
				desc = "[D]ebugger [S]tep [B]ack",
			},
			{
				"<F9>",
				function()
					require("dap").step_back()
				end,
				mode = "n",
				desc = "[D]ebugger [S]tep [B]ack",
			},
			{
				"<leader>dso",
				function()
					require("dap").step_over()
				end,
				mode = "n",
				desc = "[D]ebugger [S]tep [O]ver",
			},
			{
				"<F10>",
				function()
					require("dap").step_over()
				end,
				mode = "n",
				desc = "[D]ebugger [S]tep [O]ver",
			},
			{
				"<leader>dsi",
				function()
					require("dap").step_into()
				end,
				mode = "n",
				desc = "[D]ebugger [S]tep [I]n",
			},
			{
				"<F11>",
				function()
					require("dap").step_into()
				end,
				mode = "n",
				desc = "[D]ebugger [S]tep [I]n",
			},
			{
				"<leader>dsO",
				function()
					require("dap").step_out()
				end,
				mode = "n",
				desc = "[D]ebugger [S]tep [O]ut",
			},
			{
				"<F12>",
				function()
					require("dap").step_out()
				end,
				mode = "n",
				desc = "[D]ebugger [S]tep [O]ut",
			},
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				mode = "n",
				desc = "[D]ebugger [B]reakpoint Toggle",
			},
			{
				"<leader>dBb",
				function()
					require("dap").set_breakpoint()
				end,
				mode = "n",
				desc = "[D]ebugger [B]reakpoint Set",
			},
			{
				"<leader>dBc",
				function()
					require("dap").set_breakpoint(vim.fn.input("Condition: "), nil, nil)
				end,
				mode = "n",
				desc = "[D]ebugger [B]reakpoint [C]ondition",
			},
			{
				"<leader>dBh",
				function()
					require("dap").set_breakpoint(nil, vim.fn.input("Hit condition:"), nil)
				end,
				mode = "n",
				desc = "[D]ebugger [B]reakpoint [H]it Condition",
			},
			{
				"<leader>dBl",
				function()
					require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
				end,
				mode = "n",
				desc = "[D]ebugger [B]reakpoint [L]og Point",
			},
			{
				"<leader>dBC",
				function()
					require("dap").set_breakpoint(
						vim.fn.input("Condition: "),
						vim.fn.input("Hit Condition: "),
						vim.fn.input("Log point message: ")
					)
				end,
				mode = "n",
				desc = "[D]ebugger [B]reakpoint [C]ustom",
			},
			{
				"<leader>dor",
				function()
					require("dap").repl.open()
				end,
				mode = "n",
				desc = "[D]ebugger [O]pen [R]EPL",
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
				desc = "[D]ebugger [D]AP UI",
			},
			{
				"<leader>dc",
				function()
					require("dapui").close()
				end,
				desc = "[D]ebugger [C]lose DAP UI",
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
			local jobs = require("plugins.utils.jobs")
			jobs.maybe_pip_install("debugpy", { pyenv = vim.g.pyenv })
			require("dap-python").setup(vim.g.pyenv .. "/bin/python")
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
