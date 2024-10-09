return {
	{
		"3rd/image.nvim",
		dependencies = { "luarocks.nvim" },
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
		},
	},
}
