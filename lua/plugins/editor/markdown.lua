return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		lazy = true,
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		ft = { "markdown", "vimwiki", "Avante", "quarto", "codecompanion" },
		cond = not vim.g.vscode,
		opts = {
			file_types = { "markdown", "vimwiki", "Avante", "quarto", "codecompanion" },
			render_modes = true,
		},
	},
}
