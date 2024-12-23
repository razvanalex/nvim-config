return {
	{
		"3rd/image.nvim",
		lazy = true,
		dependencies = {
			"leafo/magick",
			"moteus/lua-path",
		},
		ft = { "markdown", "vimwiki", "quatro", "norg", "typst", "png", "jpg", "jpeg", "gif", "webp", "avif" },
		cond = not vim.g.vscode,
		opts = {
			integrations = {
				markdown = {
					only_render_image_at_cursor = true,
				},
			},
			neorg = {
				markdown = {
					only_render_image_at_cursor = true,
				},
			},
			tmux_show_only_in_active_window = true,
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge, -- this is necessary for a good experience
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},
}
