return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
		{ "nvim-lua/plenary.nvim" },
		{ "hrsh7th/nvim-cmp" },
	},
	cmd = {
		"CodeCompanion",
		"CodeCompanionActions",
		"CodeCompanionChat",
		"CodeCompanionCmd",
	},
	keys = {
		{ "<leader>cc", ":CodeCompanionChat<CR>", desc = "Open [C]odeCompanion [C]hat", mode = "n" },
		{ "<leader>ca", ":CodeCompanionActions<CR>", desc = "Open [C]odeCompanion [A]ctions", mode = "n" },
	},
	opts = {
		--Refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
		strategies = {
			agent = { adapter = "ollama" },
			chat = { adapter = "ollama" },
			inline = { adapter = "ollama" },
		},
		opts = {
			log_level = "ERROR",
		},
		display = {
			chat = {
				show_settings = true,
			},
		},
		adapters = {
			ollama = function()
				local llm = require("lua.plugins.utils.llm")
				local config = llm.get_config()

				return require("codecompanion.adapters").extend("ollama", {
					env = {
						url = config["endpoint"],
					},
					schema = {
						model = {
							default = config["model"],
						},
						num_ctx = {
							default = 16384,
						},
					},
				})
			end,
		},
	},
}
