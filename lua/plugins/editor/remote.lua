return {
	{
		"amitds1997/remote-nvim.nvim",
		version = "*", -- Pin to GitHub releases
		dependencies = {
			"nvim-lua/plenary.nvim", -- For standard functions
			"MunifTanjim/nui.nvim", -- To build the plugin UI
			"nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
		},
		opts = {
			client_callback = function(port, workspace_config)
				local cmd_nvim = ("nvim --server localhost:%s --remote-ui"):format(port)
				local cmd_tmux_new_win = ("tmux-windowizer '%s' '%s'"):format(workspace_config.host, cmd_nvim)

				vim.fn.jobstart(cmd_tmux_new_win, {
					detach = true,
					on_exit = function(job_id, exit_code, event_type)
						if exit_code ~= 0 then
							vim.notify(("Error while creating nvim remote client: exit code %s"):format(exit_code))
						end
					end,
				})
			end,
		},
		config = function(_, opts)
			if os.execute("devpod") ~= 0 then
				vim.notify(
					"devpod not found. Please check the documentation to install it https://devpod.sh/docs/getting-started/install#optional-install-devpod-cli"
				)
			end

			require("remote-nvim").setup(opts)
		end,
	},
}
