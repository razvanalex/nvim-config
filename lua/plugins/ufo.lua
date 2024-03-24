return {
	"kevinhwang91/nvim-ufo",
	dependencies = { "kevinhwang91/promise-async" },
	opts = {
		-- TODO: change folding display
		provider_selector = function(bufnr, filetype, buftype)
			return { "treesitter", "indent" }
		end,
	},
}
