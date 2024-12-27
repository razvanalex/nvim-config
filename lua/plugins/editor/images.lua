return {
	{
		"3rd/image.nvim",
		dependencies = {
			"leafo/magick",
			"moteus/lua-path",
		},
		-- lazy = true,
		-- ft = { "markdown", "vimwiki", "quatro", "norg", "typst", "png", "jpg", "jpeg", "gif", "webp", "avif" },
		cond = not vim.g.vscode,
		opts = {
			integrations = {
				markdown = {
					only_render_image_at_cursor = true,
				},
			},
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			editor_only_render_when_focused = true,
			tmux_show_only_in_active_window = true,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},
}
