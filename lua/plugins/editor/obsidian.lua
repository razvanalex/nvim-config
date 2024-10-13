return {
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		lazy = true,
		event = {
			"BufReadPre " .. os.getenv("OBSIDIAN_VAULT_PATH") .. "*.md",
			"BufNewFile " .. os.getenv("OBSIDIAN_VAULT_PATH") .. "*.md",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		cmd = {
			"ObsidianExtractNote",
			"ObsidianNew",
			"ObsidianNewFromTemplate",
			"ObsidianOpen",
			"ObsidianQuickSwitch",
			"ObsidianSearch",
			"ObsidianTags",
			"ObsidianTemplate",
			"ObsidianDailies",
			"ObsidianToday",
			"ObsidianTomorrow",
			"ObsidianYesterday",
			"ObsidianWorkspace",
		},
		opts = {
			workspaces = {
				{
					name = "obsidian",
					path = os.getenv("OBSIDIAN_VAULT_PATH"),
				},
			},
			-- It interferes with render-markdown.nvim
			ui = { enable = false },
		},
	},
}
