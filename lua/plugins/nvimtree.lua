require("nvim-tree").setup({
	hijack_directories = {
		enable = true,
		auto_open = false,
	},
})

vim.keymap.set({ "n", "v", "s", "o" }, "<C-b>", ":NvimTreeToggle<CR>")
