return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		file_types = { "markdown", "Avante" },
		opts = {
			code = { sign = false },
			ft = { "markdown", "Avante" },
			overrides = {
				buftype = {
					nofile = {
						-- Using NormalFloat seems to disable syntax highlighting
						code = { highlight = "TelescopeNormal" },
						sign = { enabled = false },
					},
				},
			},
		},
	},
}
