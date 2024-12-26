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
	keys = {
		{ "<C-b>", ":NvimTreeToggle<CR>", mode = { "n", "v", "s", "o" }, desc = "Toggle NvimTree" },
	},
	opts = {
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
	},
}
