return {
	"nvim-tree/nvim-tree.lua",
	cond = not vim.g.vscode,
	lazy = true,
	cmd = {
		"NvimTreeClipboard",
		"NvimTreeClose",
		"NvimTreeCollapse",
		"NvimTreeCollapseKeepBuffers",
		"NvimTreeFindFile",
		"NvimTreeFindFileToggle",
		"NvimTreeFocus",
		"NvimTreeHiTest",
		"NvimTreeOpen",
		"NvimTreeRefresh",
		"NvimTreeResize",
		"NvimTreeToggle",
	},
	config = function()
		require("nvim-tree").setup({
			hijack_directories = {
				enable = true,
				auto_open = false,
			},
			git = {
				enable = false,
				ignore = true,
			},
			renderer = {
				indent_markers = {
					enable = true,
				},
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = false,
					},
				},
			},

			vim.keymap.set({ "n", "v", "s", "o" }, "<C-b>", ":NvimTreeToggle<CR>"),
		})
	end,
}
