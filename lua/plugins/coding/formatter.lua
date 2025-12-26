return { -- Autoformat
	"stevearc/conform.nvim",
	event = "VeryLazy",
	cond = not vim.g.vscode,
	opts = {
		notify_on_error = true,
		format_on_save = {
			timeout_ms = 1000,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			json = { "jq" },
		},
	},
	config = function(_, opts)
		local conform = require("conform")
		conform.setup(opts)

		vim.api.nvim_create_user_command("Format", function(args)
			local range = nil
			if args.count ~= -1 then
				local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
				range = {
					start = { args.line1, 0 },
					["end"] = { args.line2, end_line:len() },
				}
			end
			conform.format({ async = true, lsp_format = "fallback", range = range })
		end, { range = true })

		-- Temporarily disable formatting on save. Useful to avoid git diffs
		-- when saving a file that does not follow formatting rules.
		local autoformat_handler = nil
		vim.api.nvim_create_user_command("DisableFormatOnSave", function()
			local handlers = vim.api.nvim_get_autocmds({
				group = "Conform",
				event = "BufWritePre",
			})
			for i, handler in ipairs(handlers) do
				if i == 1 then
					autoformat_handler = handler
				end
				vim.api.nvim_del_autocmd(handler.id)
			end
		end, {})

		-- Re-enable formatting on save. Reverts the effects of
		-- :DisableFormatOnSave.
		vim.api.nvim_create_user_command("EnableFormatOnSave", function()
			if autoformat_handler ~= nil then
				local handlers = vim.api.nvim_get_autocmds({
					group = autoformat_handler.group,
					event = "BufWritePre",
				})
				-- Add the handler only once
				if #handlers == 0 then
					vim.api.nvim_create_autocmd("BufWritePre", {
						desc = autoformat_handler.desc,
						pattern = autoformat_handler.pattern,
						group = autoformat_handler.group,
						callback = autoformat_handler.callback,
					})
				end
			end
		end, {})
	end,
}
