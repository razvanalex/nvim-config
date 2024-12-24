-- Folding code
return {
	"kevinhwang91/nvim-ufo",
	lazy = true,
    cond = not vim.g.vscode,
    event = "VeryLazy",
	dependencies = { "kevinhwang91/promise-async" },
	opts = {
		-- TODO: change folding display
		provider_selector = function(bufnr, filetype, buftype)
			return { "lsp", "indent" }
		end,
	},
}
