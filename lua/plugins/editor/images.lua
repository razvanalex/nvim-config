return {
	{
		"3rd/image.nvim",
		ft = { "markdown", "vimwiki", "quatro", "norg", "typst", "png", "jpg", "jpeg", "gif", "webp", "avif" },
		dependencies = {
			"kiyoon/magick.nvim",
		},
		cond = not vim.g.vscode,
		opts = {
			backend = "kitty",
			processor = "magick_rock",
			integrations = {
				markdown = {
					only_render_image_at_cursor = true,
					max_width = 100,
					max_height = 12,
				},
			},
			max_width = nil,
			max_height = nil,
			max_height_window_percentage = 100,
			max_width_window_percentage = 100,
			editor_only_render_when_focused = true,
			tmux_show_only_in_active_window = true,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},
}
