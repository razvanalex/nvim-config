require("neodev").setup({
	-- add any options here, or leave empty to use the default settings
	library = {
		enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
		-- these settings will be used for your Neovim config directory
		runtime = true, -- runtime path
		types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
		plugins = true, -- installed opt or start plugins in packpath
		-- you can also specify the list of plugins to make available as a workspace library
		-- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
	},
	setup_jsonls = true, -- configures jsonls to provide completion for project specific .luarc.json files
	-- for your Neovim config directory, the config.library settings will be used as is
	-- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
	-- for any other directory, config.library.enabled will be set to false
	override = function(root_dir, options) end,
	-- With lspconfig, Neodev will automatically setup your lua-language-server
	-- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
	-- in your lsp start options
	lspconfig = true,
	-- much faster, but needs a recent built of lua-language-server
	-- needs lua-language-server >= 3.6.0
	pathStrict = true,
})

local lsp = require("lsp-zero")

lsp.preset("recommended")

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = { "tsserver", "pyright", "lua_ls" },
	handlers = {
		lsp.default_setup,
		lua_ls = function()
			local lua_opts = lsp.nvim_lua_ls()
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
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
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
require("lsp_signature").setup({
	debug = false, -- set to true to enable debug logging
	log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
	-- default is  ~/.cache/nvim/lsp_signature.log
	verbose = false, -- show debug line number

	bind = true, -- This is mandatory, otherwise border config won't get registered.
	-- If you want to hook lspsaga or other signature handler, pls set to false
	doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
	-- set to 0 if you DO NOT want any API comments be shown
	-- This setting only take effect in insert mode, it does not affect signature help in normal
	-- mode, 10 by default

	max_height = 12, -- max height of signature floating_window
	max_width = 80, -- max_width of signature floating_window, line will be wrapped if exceed max_width
	-- the value need >= 40
	wrap = true, -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long
	floating_window = true, -- show hint in a floating window, set to false for virtual text only mode

	floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
	-- will set to true when fully tested, set to false will use whichever side has more space
	-- this setting will be helpful if you do not want the PUM and floating win overlap

	floating_window_off_x = 1, -- adjust float windows x position.
	-- can be either a number or function
	floating_window_off_y = 0, -- adjust float windows y position. E.g -2 move window up 2 lines; 2 move down 2 lines
	-- can be either number or function, see examples

	close_timeout = 4000, -- close floating window after ms when laster parameter is entered
	fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
	hint_enable = false, -- virtual hint enable
	hint_prefix = "🐼 ", -- Panda for parameter, NOTE: for the terminal not support emoji, might crash
	hint_scheme = "String",
	hint_inline = function()
		return false
	end, -- should the hint be inline(nvim 0.10 only)?  Default false
	-- return true | 'inline' to show hint inline, return 'eol' to show hint at end of line, return false to disable
	-- return 'right_align' to display hint right aligned in the current line
	hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
	handler_opts = {
		border = "rounded", -- double, rounded, single, shadow, none, or a table of borders
	},

	always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

	auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
	extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
	zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom

	padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc

	transparency = nil, -- disabled by default, allow floating win transparent value 1~100
	shadow_blend = 36, -- if you using shadow as border use this set the opacity
	shadow_guibg = "Black", -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
	timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
	toggle_key = nil, -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
	toggle_key_flip_floatwin_setting = false, -- true: toggle floating_windows: true|false setting after toggle key pressed
	-- false: floating_windows setup will not change, toggle_key will pop up signature helper, but signature
	-- may not popup when typing depends on floating_window setting

	select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
	move_cursor_key = nil, -- imap, use nvim_set_current_win to move cursor between current win and floating
})
