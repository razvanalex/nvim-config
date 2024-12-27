return {
	{
		"lervag/vimtex",
		lazy = true,
		cond = not vim.g.vscode,
		ft = { "latex", "tex" },
		-- tag = "v2.15", -- uncomment to pin to a specific release
		init = function()
			vim.g.vimtex_view_method = "zathura"
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
