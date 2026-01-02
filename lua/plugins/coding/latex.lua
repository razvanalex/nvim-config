local function previewStubTex()
	if vim.fn.executable("pdflatex") ~= 1 then
		vim.notify("pdflatex is not found in PATH.", vim.log.levels.ERROR)
		return
	end

	local tmpdir = "/tmp/nvim_latex_preview"
	if vim.fn.isdirectory(tmpdir) == 0 then
		vim.fn.mkdir(tmpdir, "p")
	end

	local stub_tex = [[\documentclass{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{amsthm}
\usepackage{amsfonts}
\usepackage{mathtools}
\usepackage{graphicx}
\usepackage{hyperref}
\usepackage{geometry}
\usepackage{booktabs}
\usepackage{float}
\usepackage{array}
\usepackage{multirow}
\usepackage{enumitem}
\usepackage{caption}
\usepackage{subcaption}
\usepackage{xcolor}
\usepackage{listings}
\geometry{a4paper, margin=1in}
\begin{document}
%s
\end{document}]]

	local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local body = table.concat(content, "\n")
	local full_tex = string.format(stub_tex, body)

	local tex_file = tmpdir .. "/stub.tex"
	local pdf_file = tmpdir .. "/stub.pdf"

	local f = io.open(tex_file, "w")
	if not f then
		vim.notify("Failed to write temporary LaTeX file.", vim.log.levels.ERROR)
		return
	end
	f:write(full_tex)
	f:close()

	local compile_cmd =
		string.format("pdflatex -interaction=nonstopmode -halt-on-error -output-directory=%s %s", tmpdir, tex_file)

	local jobs = require("plugins.utils.jobs")
	local promise = jobs.async_exec(compile_cmd)

	promise(function()
		if vim.g.vimtex_view_method == "zathura" then
			os.execute(string.format("zathura %s &", pdf_file))
		elseif vim.g.vimtex_view_method == "skim" then
			os.execute(string.format("open -a Skim %s", pdf_file))
		else
			vim.notify("No PDF viewer configured for LaTeX preview.", vim.log.levels.WARN)
		end
	end, function(exit_code, stdout, stderr)
		vim.notify(
			"LaTeX compilation failed (code " .. exit_code .. ").\n" .. "Stdout: " .. stdout .. "\nStderr: " .. stderr,
			vim.log.levels.ERROR
		)
	end)
end

return {
	{
		"lervag/vimtex",
		lazy = true,
		cond = not vim.g.vscode,
		ft = { "latex", "tex" },
		-- tag = "v2.15", -- uncomment to pin to a specific release
		init = function()
			local function is_executable(cmd)
				return vim.fn.executable(cmd) == 1
			end

			if is_executable("zathura") then
				vim.g.vimtex_view_method = "zathura"
			elseif is_executable("skimpdf") then
				vim.g.vimtex_view_method = "skim"
				vim.g.vimtex_view_skim_sync = 1
				vim.g.vimtex_view_skim_activate = 1

				-- Function to focus back to Vim/terminal from Skim
				vim.api.nvim_create_autocmd("User", {
					pattern = "VimtexEventViewReverse",
					callback = function()
						vim.fn.system("open -a kitty")
						vim.cmd("redraw!")
					end,
					desc = "Focus back to terminal when using backward search from Skim",
				})
			else
				vim.notify(
					"Neither Zathura nor Skim is installed. Please install one of them for PDF viewing.",
					vim.log.levels.WARN
				)
				vim.g.vimtex_view_enabled = 0
			end

			vim.g.vimtex_complete_enabled = 0
			vim.g.vimtex_doc_enabled = 0
			vim.g.vimtex_fold_enabled = 0
			vim.g.vimtex_fold_bib_enabled = 0
			vim.g.vimtex_format_enabled = 0
			vim.g.vimtex_imaps_enabled = 0
			vim.g.vimtex_include_search_enabled = 0
			vim.g.vimtex_indent_enabled = 0
			vim.g.vimtex_indent_bib_enabled = 0
			vim.g.vimtex_mappings_enabled = 1
			vim.g.vimtex_matchparen_enabled = 0
			vim.g.vimtex_motion_enabled = 0
			vim.g.vimtex_quickfix_enabled = 0
			vim.g.vimtex_syntax_enabled = 0
			vim.g.vimtex_text_obj_enabled = 0
			vim.g.vimtex_toc_enabled = 1
			vim.g.vimtex_view_enabled = 1

			vim.api.nvim_create_user_command("LatexPreviewStub", previewStubTex, {
				desc = "Preview stub for LaTeX files in temporary PDF file",
			})
		end,
	},
}
