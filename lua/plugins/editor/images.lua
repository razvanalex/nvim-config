return {
	{
		"3rd/image.nvim",
		lazy = true,
		module = "image",
		init = function()
			if not vim.env.TMUX or vim.env.TMUX == "" then
				return
			end

			local handle = io.popen("tty 2>/dev/null")
			local current_tty = handle and handle:read("*a") or ""
			if handle then
				handle:close()
			end
			current_tty = vim.fn.trim(current_tty)

			local tmux_tty = vim.fn.system({ "tmux", "display-message", "-p", "#{pane_tty}" })
			tmux_tty = vim.fn.trim(tmux_tty)

			if vim.v.shell_error ~= 0 or tmux_tty == "" or (current_tty ~= "" and tmux_tty ~= current_tty) then
				vim.g.image_nvim_tmux_env = vim.env.TMUX
				vim.env.TMUX = nil
			end
		end,
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
			editor_only_render_when_focused = false,
			tmux_show_only_in_active_window = false,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
			hijack_file_patterns = {},
		},
	},
}
