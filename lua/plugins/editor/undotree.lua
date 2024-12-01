return { -- fancy undo
	"mbbill/undotree",
	cmd = {
		"UndotreeFocus",
		"UndotreeHide",
		"UndotreePersistUndo",
		"UndotreeShow",
		"UndotreeToggle",
	},
	cond = not vim.g.vscode,
	lazy = true,
	keys = {
		{ "<leader>u", vim.cmd.UndotreeToggle, desc = "[U]ndoTree Toggle" },
	},
	init = function()
		if vim.fn.has("persistent_undo") ~= 0 then
			local target_path = vim.fn.expand("~/.undodir")

			if vim.fn.isdirectory(target_path) == 0 then
				vim.fn.mkdir(target_path, "p", "0700")
			end
			vim.opt.undodir = target_path
			vim.opt.undofile = true
		end
	end,
}
