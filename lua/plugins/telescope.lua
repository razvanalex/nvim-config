local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope File Finder" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope Live Grep" })
vim.keymap.set("n", "<leader>fv", builtin.git_files, { desc = "Telescope Git Files" })
vim.keymap.set("n", "<leader>ps", function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope Help Tags" })
