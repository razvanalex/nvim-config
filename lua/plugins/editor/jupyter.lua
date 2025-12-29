---@alias NewNotebookCallback fun(): nil

--- Get file paths for cleanup
---@param base_dir string|nil The directory (defaults to current file directory)
---@param base_name string|nil The base filename (defaults to current file basename)
---@return table { html: string, files_dir: string }
local function get_preview_paths(base_dir, base_name)
	local dir = base_dir or vim.fn.expand("%:p:h")
	local name = base_name or vim.fn.expand("%:t:r")

	return {
		html = dir .. "/" .. name .. ".html",
		files_dir = dir .. "/" .. name .. "_files",
	}
end

--- Check if file should be cleaned up (notebook or jupytext-generated qmd)
---@return boolean
local function should_cleanup_preview()
	local current_ext = vim.fn.expand("%:e")

	if current_ext == "ipynb" then
		return true
	end
	if current_ext == "qmd" then
		local current_dir = vim.fn.expand("%:p:h")
		local basename = vim.fn.expand("%:t:r")
		local ipynb_file = current_dir .. "/" .. basename .. ".ipynb"

		return vim.fn.filereadable(ipynb_file) == 1
	end

	return false
end

--- Clean up preview HTML files
---@param notify boolean|nil Whether to show notifications (default: false)
local function cleanup_preview_files(notify)
	local paths = get_preview_paths()
	local cleaned = false

	if vim.fn.filereadable(paths.html) == 1 then
		vim.fn.delete(paths.html)
		cleaned = true
		if notify then
			vim.notify("Deleted: " .. vim.fn.fnamemodify(paths.html, ":t"), vim.log.levels.INFO)
		end
	end

	if vim.fn.isdirectory(paths.files_dir) == 1 then
		vim.fn.delete(paths.files_dir, "rf")
		cleaned = true
		if notify then
			vim.notify("Deleted: " .. vim.fn.fnamemodify(paths.files_dir, ":t") .. "/", vim.log.levels.INFO)
		end
	end

	return cleaned
end

--- Add snippet for new notebook files
---@param callback NewNotebookCallback | nil The function to run after the snippet is added.
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
				vim.cmd(":w")
				if callback then
					callback()
				end
			end
		end,
	})
end

--- Check if cursor is currently inside a code cell
--- @param cell_markers table Table of cell marker patterns per filetype
--- @return boolean
local function is_inside_cell(cell_markers)
	local current_line = vim.fn.line(".")
	local ft = vim.bo.filetype
	local patterns = cell_markers[ft] or cell_markers.quarto

	local cell_start = 0
	for _, pattern in ipairs(patterns) do
		cell_start = vim.fn.search(pattern, "bnW")
		if cell_start > 0 then
			break
		end
	end

	return cell_start > 0 and cell_start < current_line
end

--- Jump to a code cell in the specified direction
--- @param cell_markers table Table of cell marker patterns per filetype
--- @param direction string "next" or "prev"
--- @return boolean Whether a cell was found and jumped to
local function jump_to_cell(cell_markers, direction)
	local current_line = vim.fn.line(".")
	local total_lines = vim.fn.line("$")
	local ft = vim.bo.filetype

	local patterns = cell_markers[ft] or cell_markers.quarto

	-- Search flags:
	--   "n" = don't move cursor
	--   "W" = don't wrap
	--   "b" = search backwards for previous
	local flags = direction == "prev" and "bnW" or "nW"

	if direction == "prev" and current_line > 2 then
		-- For backwards search, temporarily move up 2 lines to skip
		-- current cell marker
		vim.fn.cursor(current_line - 2, 0)
	end

	local target_line = 0
	for _, pattern in ipairs(patterns) do
		target_line = vim.fn.search(pattern, flags)
		if target_line > 0 then
			break
		end
	end

	-- Restore original position
	vim.fn.cursor(current_line, 0)

	local is_valid = false
	if direction == "next" then
		is_valid = target_line > current_line and target_line <= total_lines
	else
		is_valid = target_line > 0 and target_line < current_line
	end

	if is_valid then
		-- Moving to the next line ensures quarto can detect the language
		-- from the code block.
		vim.fn.cursor(target_line + 1, 0)
		vim.cmd("normal! zz")
		return true
	end

	return false
end

local cell_markers = {
	quarto = { "^```{.*}$" },
	markdown = { "^```{.*}$" },
	python = { "^# *%%", "^#%%", "^# *<codecell>" },
}

local function jump_to_next_cell()
	jump_to_cell(cell_markers, "next")
end

local function jump_to_prev_cell()
	jump_to_cell(cell_markers, "prev")
end

local function run_cell_and_jump()
	if not is_inside_cell(cell_markers) then
		jump_to_next_cell()
	end

	require("quarto.runner").run_cell()

	jump_to_next_cell()
end

local function setup_auto_cleanup()
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = vim.api.nvim_create_augroup("quarto-cleanup-on-exit", { clear = true }),
		pattern = { "*.qmd", "*.ipynb" },
		callback = function()
			if should_cleanup_preview() then
				cleanup_preview_files(false)
			end
		end,
	})
end

return {
	{
		-- Quarto integration for notebooks and literate programming
		"quarto-dev/quarto-nvim",
		lazy = true,
		ft = { "ipynb", "quarto" },
		cond = not vim.g.vscode,
		dependencies = {
			"jmbuhr/otter.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			lspFeatures = {
				chunks = "all",
			},
			codeRunner = {
				enabled = true,
				default_method = "iron",
				never_run = { "yaml" },
			},
		},
		keys = {
			{
				"<localleader><CR>",
				run_cell_and_jump,
				desc = "Run Cell & Jump to Next",
				silent = true,
				mode = "n",
			},
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
				"<localleader>qrb",
				function()
					require("quarto.runner").run_below()
				end,
				desc = "[Q]uarto [R]un Cell and [B]elow",
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
			{
				"<localleader>qp",
				function()
					require("quarto").quartoPreview({})
				end,
				desc = "[Q]uarto [P]review",
				silent = true,
				mode = "n",
			},
			{
				"<localleader>qP",
				function()
					require("quarto").quartoClosePreview()
					cleanup_preview_files(true)
				end,
				desc = "[Q]uarto Stop [P]review & Cleanup",
				silent = true,
				mode = "n",
			},
			{
				"]x",
				jump_to_next_cell,
				desc = "Jump to Next Cell",
				silent = true,
				mode = "n",
			},
			{
				"[x",
				jump_to_prev_cell,
				desc = "Jump to Previous Cell",
				silent = true,
				mode = "n",
			},
		},
		config = function(_, opts)
			if vim.fn.executable("quarto") ~= 1 then
				vim.notify(
					"Error: quarto-cli not found. Please download from https://quarto.org/docs/download/",
					vim.log.levels.ERROR
				)
				return
			end

			require("quarto").setup(opts)
			setup_auto_cleanup()
		end,
	},
	{
		-- LSP support inside markdown and quarto code blocks
		"jmbuhr/otter.nvim",
		lazy = true,
		ft = { "quarto" },
		cond = not vim.g.vscode,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {},
	},
	{
		-- Convert jupyter notebooks to quarto/markdown
		"GCBallesteros/jupytext.nvim",
		lazy = false,
		ft = "ipynb",
		cond = not vim.g.vscode,
		opts = {
			custom_language_formatting = {
				python = {
					extension = "qmd",
					style = "quarto",
					force_ft = "quarto",
				},
			},
			formats = "ipynb,qmd",
			sync_on_save = true,
		},
		config = function(_, opts)
			local jobs = require("plugins.utils.jobs")
			local callback = jobs.exec_once(function()
				require("jupytext").setup(opts)
			end)
			new_notebook_snippet()

			jobs.maybe_pip_install("jupytext", {
				newly_installed_cb = callback,
				already_installed_cb = callback,
				pyenv = vim.g.pyenv,
			})
		end,
	},
}
