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
		end,
	},
}
