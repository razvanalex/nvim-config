return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		file_types = { "markdown", "vimwiki", "Avante" },
		opts = {
			code = { sign = false },
			file_types = { "markdown", "vimwiki", "Avante" },
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
