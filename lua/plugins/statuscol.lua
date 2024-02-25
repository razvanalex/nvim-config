local builtin = require("statuscol.builtin")

vim.o.foldcolumn = "1"
vim.o.foldmethod = "indent"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

require("statuscol").setup({
	setopt = true, -- Whether to set the 'statuscolumn' option, may be set to false for those who
	-- want to use the click handlers in their own 'statuscolumn': _G.Sc[SFL]a().
	-- Although I recommend just using the segments field below to build your
	-- statuscolumn to benefit from the performance optimizations in this plugin.
	-- builtin.lnumfunc number string options
	thousands = false, -- or line number thousands separator string ("." / ",")
	relculright = true, -- whether to right-align the cursor line number with 'relativenumber' set
	-- Builtin 'statuscolumn' options
	ft_ignore = nil, -- lua table with 'filetype' values for which 'statuscolumn' will be unset
	bt_ignore = nil, -- lua table with 'buftype' values for which 'statuscolumn' will be unset
	-- Default segments (fold -> sign -> line number + separator), explained below
	segments = {
		{
			sign = { name = { "Diagnostic" }, maxwidth = 1, colwidth = 1, auto = true },
			click = "v:lua.ScSa",
		},
		{
			sign = { name = { ".*" }, maxwidth = 1, auto = true },
			click = "v:lua.ScSa",
		},
		{ text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
		{
			text = { " " },
			condition = {
				function(args)
					return args.relnum == 0
				end,
			},
		},
		{
			sign = { namespace = { "gitsigns_extmark_signs_" }, maxwidth = 1, colwidth = 1, auto = false },
			click = "v:lua.ScSa",
		},
		{ text = { builtin.foldfunc }, click = "v:lua.ScFa" },
	},
	clickmod = "c", -- modifier used for certain actions in the builtin clickhandlers:
	-- "a" for Alt, "c" for Ctrl and "m" for Meta.
	clickhandlers = { -- builtin click handlers
		Lnum = builtin.lnum_click,
		FoldClose = builtin.foldclose_click,
		FolOpen = builtin.foldopen_click,
		FoldOther = builtin.foldother_click,
		DapBreakpointRejected = builtin.toggle_breakpoint,
		DapBreakpoint = builtin.toggle_breakpoint,
		DapBreakpointCondition = builtin.toggle_breakpoint,
		DiagnosticSignError = builtin.diagnostic_click,
		DiagnosticSignHint = builtin.diagnostic_click,
		DiagnosticSignInfo = builtin.diagnostic_click,
		DiagnosticSignWarn = builtin.diagnostic_click,
		GitSignsTopdelete = builtin.gitsigns_click,
		GitSignsUntracked = builtin.gitsigns_click,
		GitSignsAdd = builtin.gitsigns_click,
		GitSignsChange = builtin.gitsigns_click,
		GitSignsChangedelete = builtin.gitsigns_click,
		GitSignsDelete = builtin.gitsigns_click,
		gitsigns_extmark_signs_ = builtin.gitsigns_click,
	},
})
