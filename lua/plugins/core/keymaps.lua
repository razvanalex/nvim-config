vim.keymap.set("n", "<leader>pv", ":Ex<CR>", { desc = "Open File Explorer" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected line up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Remove endline" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Keep the coursor in the center of the screen" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Keep the coursor in the center of the screen" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Go next search item, center the cursor, open fold" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Go prev search item, center the cursor, open fold" })

-- greatest remap ever
vim.keymap.set("x", "<leader>P", [["_dP]], { desc = "[P]aste without overwriting the register" })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank into the system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank current line into the system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>D", [["_d]], { desc = "Deletes without saving in clipboard" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set({ "n", "i" }, "<C-Enter>", "<Esc>o", { desc = "New Line Below" })

vim.keymap.set("n", "<C-t>n", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Sessionize tmux" })

vim.keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next [Q]uickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "Prev [Q]uickfix" })
vim.keymap.set("n", "]l", "<cmd>lnext<CR>zz", { desc = "Next [L]ocation" })
vim.keymap.set("n", "[l", "<cmd>lprev<CR>zz", { desc = "Prev [L]ocation" })

vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Edit all occurences under the coursor" }
)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- wintabs
vim.keymap.set({ "n", "v", "s", "o" }, "<C-T>k", "<Plug>(wintabs_previous)", { desc = "Previous wintab" })
vim.keymap.set({ "n", "v", "s", "o" }, "<C-T>l", "<Plug>(wintabs_next)", { desc = "Next wintab" })
vim.keymap.set({ "n", "v", "s", "o" }, "<C-T>c", "<Plug>(wintabs_close)", { desc = "Close wintab" })
vim.keymap.set({ "n", "v", "s", "o" }, "<C-T>u", "<Plug>(wintabs_undo)", { desc = "Undo wintab" })
vim.keymap.set({ "n", "v", "s", "o" }, "<C-T>o", "<Plug>(wintabs_only)", { desc = "Only wintabs" })
vim.keymap.set({ "n", "v", "s", "o" }, "<C-W>c", "<Plug>(wintabs_close_window)", { desc = "Close window" })
vim.keymap.set({ "n", "v", "s", "o" }, "<C-W>o", "<Plug>(wintabs_only_window)", { desc = "Only window" })

vim.api.nvim_create_user_command("Tabc", "WintabsCloseVimtab", {})
vim.api.nvim_create_user_command("Tabo", "WintabsOnlyVimtab", {})

-- Too often press :W instead of :w to save a file
vim.api.nvim_create_user_command("W", "w", {})

vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { desc = "Exit terminal mode", noremap = true })
