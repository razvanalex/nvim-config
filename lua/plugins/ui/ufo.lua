return {
	"kevinhwang91/nvim-ufo",
	dependencies = { "kevinhwang91/promise-async" },
	cond = not vim.g.vscode,
	event = "VeryLazy",
	opts = {
		-- TODO: change folding display
		provider_selector = function(bufnr, filetype, buftype)
			return { "lsp", "indent" }
		end,
	},
}
