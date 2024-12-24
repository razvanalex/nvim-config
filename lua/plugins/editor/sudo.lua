return {
	"lambdalisue/suda.vim", -- Save wit sudo if forgot to open with `sudo nvim ...`
    cond = not vim.g.vscode,
    init = function()
        vim.g.suda_smart_edit = 1
    end
}
