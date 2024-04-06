return {
	{
		"mfussenegger/nvim-dap",
		cond = not vim.g.vscode,
		config = function()
			-- key mappings
			vim.keymap.set("n", "<F5>", function()
				require("dap").set_log_level("TRACE")
				if vim.fn.filereadable(".vscode/launch.json") then
					require("dap.ext.vscode").load_launchjs(nil, {
						-- NOTE: Add missing mappings. Check the type names
						-- with !lua vim.print(require("dap").configurations)
						debugpy = { "python" },
					})
				end
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

			vim.keymap.set("n", "<Leader>db", function()
				require("dap").toggle_breakpoint()
			end, { desc = "[D]ebugger Toggle [B]reakpoint" })

			vim.keymap.set("n", "<Leader>dB", function()
				require("dap").set_breakpoint()
			end, { desc = "[D]ebugger Set [B]reakpoint" })

			vim.keymap.set("n", "<Leader>dlp", function()
				require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
			end, { desc = "[D]ebugger Set [L]og [P]oint" })

			vim.keymap.set("n", "<Leader>dr", function()
				require("dap").repl.open()
			end, { desc = "[D]ebugger Open [R]EPL" })

			vim.keymap.set("n", "<Leader>dl", function()
				require("dap").run_last()
			end, { desc = "[D]ebugger Run [L]ast" })

			vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
				require("dap.ui.widgets").hover()
			end, { desc = "[D]ebugger [H]over Widget" })

			vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
				require("dap.ui.widgets").preview()
			end, { desc = "[D]ebugger [P]review Widget" })

			vim.keymap.set("n", "<Leader>dff", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.frames)
			end, { desc = "[D]ebugger [F]loat [F]rames" })

			vim.keymap.set("n", "<Leader>dfs", function()
				local widgets = require("dap.ui.widgets")
				widgets.centered_float(widgets.scopes)
			end, { desc = "[D]ebugger [F]loat [S]copes" })

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
		cond = not vim.g.vscode,
		config = function()
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
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			vim.keymap.set("n", "<leader>dd", function()
				dapui.open()
			end, { desc = "[D]ebugger Open [D]AP mode" })

			vim.keymap.set("n", "<leader>dc", function()
				dapui.close()
			end, { desc = "[D]ebugger [C]lose DAP mode" })
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
		cond = not vim.g.vscode,
		config = function()
			require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
		end,
	},
	{ "leoluz/nvim-dap-go", opts = {}, cond = not vim.g.vscode }, -- Go DAP
}
