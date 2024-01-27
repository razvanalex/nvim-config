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
	local function get_opts(other_opts)
		local o = { buffer = bufnr, remap = false }
		for k, v in pairs(other_opts) do
			o[k] = v
		end
		return o
	end

	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover()
	end, get_opts({ desc = "Hover" }))
	vim.keymap.set("n", "gd", function()
		vim.lsp.buf.definition()
	end, get_opts({ desc = "Go Definition" }))
	vim.keymap.set("n", "gD", function()
		vim.lsp.buf.declaration()
	end, get_opts({ desc = "Go Declaration" }))
	vim.keymap.set("n", "gi", function()
		vim.lsp.buf.implementation()
	end, get_opts({ desc = "List Implementations" }))
	vim.keymap.set("n", "go", function()
		vim.lsp.buf.type_definition()
	end, get_opts({ desc = "Go Type Definition" }))
	vim.keymap.set("n", "gr", function()
		vim.lsp.buf.references()
	end, get_opts({ desc = "Go References" }))
	vim.keymap.set("i", "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, get_opts({ desc = "Signature Help" }))
	vim.keymap.set("n", "<F2>", function()
		vim.lsp.buf.rename()
	end, get_opts({ desc = "Rename Symbol" }))
	vim.keymap.set("n", "<F3>", function()
		vim.lsp.buf.format()
	end, get_opts({ desc = "Format Current Buffer" }))
	vim.keymap.set("n", "<F4>", function()
		vim.lsp.buf.code_action()
	end, get_opts({ desc = "Code Action" }))
	vim.keymap.set("n", "gl", function()
		vim.diagnostic.open_float()
	end, get_opts({ desc = "Show Diagnostics" }))
	vim.keymap.set("n", "gw", function()
		vim.lsp.buf.workspace_symbol()
	end, get_opts({ desc = "Show Workspace Symbols" }))
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.goto_next()
	end, get_opts({ desc = "Next Diagnostic" }))
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.goto_prev()
	end, get_opts({ desc = "Previous Diagnostic" }))
end)

lsp.set_sign_icons({
	error = "",
	warn = "",
	hint = "",
	info = "",
})

lsp.setup()

vim.diagnostic.config({
	virtual_text = false,
})

lsp.set_server_config({
	capabilities = {
		textDocument = {
			foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			},
		},
	},
})

require("luasnip.loaders.from_vscode").lazy_load()
