local function init_molten()
	-- automatically import output chunks from a jupyter notebook
	-- tries to find a kernel that matches the kernel in the jupyter notebook
	-- falls back to a kernel that matches the name of the active venv (if any)
	local imb = function(e) -- init molten buffer
		vim.schedule(function()
			local kernels = vim.fn.MoltenAvailableKernels()
			local try_kernel_name = function()
				local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
				return metadata.kernelspec.name
			end
			local ok, kernel_name = pcall(try_kernel_name)
			if not ok or not vim.tbl_contains(kernels, kernel_name) then
				kernel_name = nil
				local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
				if venv ~= nil then
					kernel_name = string.match(venv, "/.+/(.+)")
				end
			end
			if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
				vim.cmd(("MoltenInit %s"):format(kernel_name))
			end
			vim.cmd("MoltenImportOutput")
		end)
	end

	-- automatically import output chunks from a jupyter notebook
	vim.api.nvim_create_autocmd("BufAdd", {
		pattern = { "*.ipynb" },
		callback = imb,
	})

	-- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = { "*.ipynb" },
		callback = function(e)
			if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
				imb(e)
			end
		end,
	})

	-- automatically export output chunks to a jupyter notebook on write
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = { "*.ipynb" },
		callback = function()
			if require("molten.status").initialized() == "Molten" then
				vim.cmd("MoltenExportOutput!")
			end
		end,
	})
end
--- Add snippet for new files.
---@param callback function The function to run after the snippet is added.
local function new_notebook_snippet(callback)
	local buf = require("plugins.utils.buffer")
	local lines = {
		"{",
		'  "cells": [',
		"    {",
		'      "cell_type": "markdown",',
		'      "metadata": {},',
		'      "source": [',
		'        ""',
		"      ]",
		"    }",
		"  ],",
		'  "metadata": {',
		'    "kernelspec": {',
		'      "display_name": "Python 3",',
		'      "language": "python",',
		'      "name": "python3"',
		"    },",
		'    "language_info": {',
		'      "codemirror_mode": {',
		'        "name": "ipython"',
		"      },",
		'      "file_extension": ".py",',
		'      "mimetype": "text/x-python",',
		'      "name": "python",',
		'      "nbconvert_exporter": "python",',
		'      "pygments_lexer": "ipython3"',
		"    }",
		"  },",
		'  "nbformat": 4,',
		'  "nbformat_minor": 5',
		"}",
	}

	vim.api.nvim_create_autocmd({ "BufRead", "BufReadCmd" }, {
		group = vim.api.nvim_create_augroup("new-notebook.ipynb", { clear = true }),
		pattern = "*.ipynb",
		callback = function(args)
			if (args.event ~= "BufReadCmd" and buf.is_buffer_empty()) or vim.fn.filereadable(args.match) == 0 then
				vim.api.nvim_buf_set_lines(args.buf, 0, -1, true, lines)
				vim.cmd(":w") -- The file must be created
				callback()
			end
		end,
	})
end

---@return string
local function get_project_name()
	local active_venv_path = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
	if active_venv_path == nil then
		active_venv_path = vim.cmd("!pwd")
	end
	return "kernel-" .. active_venv_path:gsub("[^%w%.%-_]", "-")
end

return {
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		event = "VeryLazy",
		cond = not vim.g.vscode,
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			local jobs = require("plugins.utils.jobs")
			local install_ipykernel = jobs.exec_once(function()
				jobs.maybe_pip_install("ipykernel", {
					prompt_installation = true,
					newly_installed_cb = function()
						local project_name = get_project_name()
						local cmd = string.format("python -m ipykernel install --user --name %s", project_name)
						local job = jobs.async_exec(cmd)

						job(function()
							vim.notify(string.format("Created ipykernel kernel: %s", project_name), vim.log.levels.INFO)
						end, function()
							vim.notify(string.format("Failed to create kernel: %s", cmd), vim.log.levels.ERROR)
						end)
					end,
				})
			end)

			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = false
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true

			-- Make sure deps are installed
			vim.api.nvim_create_autocmd({ "BufEnter" }, {
				pattern = { "*.ipynb" },
				callback = function(_)
					jobs.maybe_pip_install({
						-- required
						"pynvim",
						"jupyter_client",
						-- optional
						"CairoSVG",
						"pnglatex",
						"plotly",
						"kaleido",
						"pyperclip",
						"nbformat",
						"pillow",
						"requests",
						"websocket-client",
					}, { pyenv = vim.g.pyenv })

					install_ipykernel()
				end,
			})

			-- FIXME:
			init_molten()
		end,
		keys = {
			{ "<localleader>me", ":MoltenEvaluateOperator<CR>", desc = "[M]olten [E]valuate Operator", silent = true },
			{ "<localleader>mr", ":MoltenReevaluateCell<CR>", desc = "[M]olten [R]e-evaluate Cell", silent = true },
			{
				"<localleader>moe",
				":noautocmd MoltenEnterOutput<CR>",
				desc = "[M]olten [O]utput [E]nter Window",
				silent = true,
			},
			{ "<localleader>moh", ":MoltenHideOutput<CR>", desc = "[M]olten [O]utput [H]ide Window", silent = true },
			{ "<localleader>md", ":MoltenDelete<CR>", desc = "[M]olten [D]elete [C]ell", silent = true },
			{ "<localleader>mx", ":MoltenOpenInBrowser<CR>", desc = "[M]olten Open Output in Browser", silent = true },
		},
	},
	{
		-- Special format that works the best.
		"quarto-dev/quarto-nvim",
		ft = { "quarto", "markdown" },
		cond = not vim.g.vscode,
		dependencies = {
			"jmbuhr/otter.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			debug = false,
			closePreviewOnExit = true,
			lspFeatures = {
				enabled = true,
				chunks = "all",
				languages = { "r", "python", "julia", "bash", "html" },
				diagnostics = {
					enabled = true,
					triggers = { "BufWritePost" },
				},
				completion = {
					enabled = true,
				},
			},
			keymap = {
				hover = "K",
				definition = "gd",
				rename = "<F2>",
				references = "grr",
				format = "==",
			},
			codeRunner = {
				enabled = true,
				default_method = "molten", -- 'molten' or 'slime'
				-- ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
				-- Takes precedence over `default_method`
				never_run = { "yaml" }, -- filetypes which are never sent to a code runner
			},
		},
		config = function(_, opts)
			require("quarto").setup(opts)
			require("quarto").activate()
		end,
		keys = {
			{
				"<localleader>qrc",
				function()
					require("quarto.runner").run_cell()
				end,
				desc = "[Q]uarto [R]un [C]ell",
				silent = true,
				mode = "n",
			},
			{
				"<localleader>qra",
				function()
					require("quarto.runner").run_above()
				end,
				desc = "[Q]uarto [R]un Cell and [A]bove",
				silent = true,
				mode = "n",
			},
			{
				"<localleader>qrA",
				function()
					require("quarto.runner").run_all()
				end,
				desc = "[Q]uarto [R]un [A]ll Cells",
				silent = true,
				mode = "n",
			},
			{
				"<localleader>qrl",
				function()
					require("quarto.runner").run_line()
				end,
				desc = "[Q]uarto [R]un [L]ine",
				silent = true,
				mode = "n",
			},
			{
				"<localleader>qr",
				function()
					require("quarto.runner").run_range()
				end,
				desc = "[Q]uarto [R]un Visual Range",
				silent = true,
				mode = "v",
			},
			{
				"<localleader>qRA",
				function()
					require("quarto.runner").run_all(true)
				end,
				desc = "[Q]uarto [R]un [A]ll Cells of All Languages",
				silent = true,
				mode = "n",
			},
		},
	},
	{
		-- LSP inside markdown and quarto
		"jmbuhr/otter.nvim",
		event = "VeryLazy",
		ft = { "quatro", "markdown" },
		cond = not vim.g.vscode,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {},
	},
	{
		-- Convert jupyter notebooks to quarto/markdown and the other way
		"GCBallesteros/jupytext.nvim",
		ft = "ipynb",
		cond = not vim.g.vscode,
		opts = {
			-- style = "hydrogen",
			-- output_extension = "auto",
			-- force_ft = nil,

			style = "markdown",
			output_extension = "md",
			force_ft = "markdown",
		},
		config = function(_, opts)
			-- Here is where the magic happens:
			--   - it installs jupytext automatically in the current environment
			--   - it auto-generates an empty notebook upon file/buffer creation
			--   - if the ipynb file is empty, it will be auto-generated
			--
			-- One caveat though: the file will be automatically saved on creation,
			-- otherwise the plugin doesn't work.
			local jobs = require("plugins.utils.jobs")
			local reopen_file = function()
				vim.cmd(":e") -- Reopen the file to trigger BufReadCmd event
			end
			local callback = jobs.exec_once(function()
				require("jupytext").setup(opts)
				reopen_file()
			end)
			new_notebook_snippet(reopen_file)

			jobs.maybe_pip_install("jupytext", {
				newly_installed_cb = callback,
				already_installed_cb = callback,
				pyenv = vim.g.pyenv,
			})
		end,
	},
}
