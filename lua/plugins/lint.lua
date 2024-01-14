local lint = require("lint")
lint.linters_by_ft = {
	markdown = { "vale" },
	python = { "pylint" },
}

vim.g.lint = false

vim.api.nvim_create_user_command("LintToggle", function()
	vim.g.lint = not vim.g.lint
	if vim.g.lint then
		lint.try_lint()
	else
		vim.diagnostic.reset(nil, 0)
		-- TODO: redraw the lsp output. right now, it can be redrawn manually
		-- by entering/exiting insert mode.
	end
end, { desc = "Toggle linter" })

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		if vim.g.lint then
			lint.try_lint()
		end
	end,
})
