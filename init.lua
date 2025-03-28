require("plugins.core.options")
require("plugins.core.keymaps")

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins, you can run
--    :Lazy update
--
require("lazy").setup({
	{ import = "plugins" },
	{ import = "plugins.local" },
	{ import = "plugins.coding" },
	{ import = "plugins.core.luarocks" },
	{ import = "plugins.editor" },
	{ import = "plugins.extras" },
	{ import = "plugins.llm" },
	{ import = "plugins.navigation" },
	{ import = "plugins.ui" },
}, {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
	rocks = {
		hererocks = true,
	},
})
