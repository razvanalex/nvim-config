require("nvim-tree").setup()

vim.keymap.set({ "n", "v", "s", "o" }, "<C-b>", ":NvimTreeToggle<CR>")
