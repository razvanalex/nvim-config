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
}
