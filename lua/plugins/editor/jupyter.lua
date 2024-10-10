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

			-- TODO: Try to automatically launch the kernel. Save in a file the mapping.
			-- Also, if no kernel found, prompt the user to select one.
			--
			-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
			-- 	pattern = { "*.ipynb" },
			-- 	callback = function(_)
			-- 		local project_name = get_project_name()
			-- 		if project_name ~= nil then
			-- 			vim.cmd(("MoltenInit %s"):format(project_name))
			-- 		end
			-- 	end,
			-- })
		end,
	},
	{
		-- Special format that works the best.
		"quarto-dev/quarto-nvim",
		ft = { "quarto", "markdown" },
		-- event = "VeryLazy",
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
				chunks = "curly",
				languages = { "r", "python", "julia", "bash", "html" },
				diagnostics = {
					enabled = true,
					triggers = { "BufWritePost" },
				},
				completion = {
					enabled = true,
				},
			},
			codeRunner = {
				enabled = true,
				default_method = "molten", -- 'molten' or 'slime'
				-- ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
				-- Takes precedence over `default_method`
				never_run = { "yaml" }, -- filetypes which are never sent to a code runner
			},
		},
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
		config = function(opts)
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
