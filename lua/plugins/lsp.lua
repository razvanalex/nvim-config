local lsp = require("lsp-zero")

lsp.preset("recommended")

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = { "tsserver", "pyright" },
	handlers = {
		lsp.default_setup,
		lua_ls = function()
			local lua_opts = lsp_zero.nvim_lua_ls()
			require("lspconfig").lua_ls.setup(lua_opts)
		end,
	},
})

local cmp = require("cmp")
local cmp_action = lsp.cmp_action()
local lspkind = require("lspkind")

cmp.setup({
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-f>"] = cmp_action.luasnip_jump_forward(),
		["<C-b>"] = cmp_action.luasnip_jump_backward(),
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		["<CR>"] = cmp.mapping.confirm({ select = false }),
		["C-y"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp_action.luasnip_supertab(),
		["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
	}),
	sources = cmp.config.sources({
		{ name = "path" },
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
		{ name = "buffer" },
	}),
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol_text", -- show only symbol annotations
			preset = "codicons",
			maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
			-- can also be a function to dynamically calculate max width such as
			-- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
			ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
			show_labelDetails = true, -- show labelDetails in menu. Disabled by default

			-- The function below will be called before any actual modifications from lspkind
			-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
			before = function(entry, vim_item)
				return vim_item
			end,
		}),
	},
})

lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({ buffer = bufnr })
	vim.keymap.set("i", "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, opts)

	-- local opts = {buffer = bufnr, remap = false}
	--
	-- vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
	-- vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
	-- vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
	-- vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
	-- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
	-- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
	-- vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
	-- vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
	-- vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
	-- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.set_sign_icons({
	error = "",
	warn = "",
	hint = "",
	info = "",
})

lsp.setup()

vim.diagnostic.config({
	virtual_text = true,
})

require("luasnip.loaders.from_vscode").lazy_load()
