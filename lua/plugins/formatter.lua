return { -- Autoformat
	"stevearc/conform.nvim",
	opts = {
		notify_on_error = false,
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
		formatters_by_ft = {
			lua = { "stylua" },
			-- Conform can also run multiple formatters sequentially
			python = { "isort", "black" },
			--
			-- You can use a sub-list to tell conform to run *until* a formatter
			-- is found.
			-- javascript = { { "prettierd", "prettier" } },
		},
	},
	-- config = function()
	-- 	-- autoformat on save
	-- 	local augroup = vim.api.nvim_create_augroup
	-- 	local autocmd = vim.api.nvim_create_autocmd
	--
	-- 	augroup("__formatter__", { clear = true })
	-- 	autocmd("BufWritePost", {
	-- 		group = "__formatter__",
	-- 		command = ":FormatWrite",
	-- 	})
	--
	-- 	vim.keymap.set("n", "<C-f>", ":Format<CR>", { desc = "[F]ormat Document" })
	-- end,
}
