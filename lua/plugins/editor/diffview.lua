return {
	"sindrets/diffview.nvim",
	lazy = true,
	cond = not vim.g.vscode,
	cmd = {
		"DiffviewClose",
		"DiffviewFileHistory",
		"DiffviewFocusFiles",
		"DiffviewLog",
		"DiffviewOpen",
		"DiffviewRefresh",
		"DiffviewToggleFiles",
		"DisableAutoSave",
	},
	opts = {
		hooks = {
			---@param view StandardView
			view_opened = function(view)
				-- Highlight 'DiffChange' as 'DiffDelete' on the left, and 'DiffAdd' on the right.
				local function post_layout()
					local tbl = require("plugins.utils.table")

					tbl.ensure(view, "winopts.diff2.a")
					tbl.ensure(view, "winopts.diff2.b")
					-- left
					view.winopts.diff2.a = tbl.union_extend(view.winopts.diff2.a, {
						winhl = {
							"DiffChange:DiffviewDelete",
							"DiffText:DiffviewDeleteText",
							"DiffDelete:DiffviewDiffDelete",
							"DiffAdd:DiffviewDeleteText",
						},
					})
					-- right
					view.winopts.diff2.b = tbl.union_extend(view.winopts.diff2.b, {
						winhl = {
							"DiffChange:DiffviewAdd",
							"DiffText:DiffviewAddText",
							"DiffAdd:DiffviewAddText",
							"DiffDelete:DiffviewDiffDelete",
						},
					})
				end

				post_layout()
			end,
		}, -- See ':h diffview-config-hooks'
		view = {
			default = {
				winbar_info = true,
			},
			file_history = {
				winbar_info = true,
			},
			merge_tool = {
				layout = "diff3_mixed",
			},
		},
	},
}
