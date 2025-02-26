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
			agent = { adapter = "openai_compatible" },
			chat = { adapter = "openai_compatible" },
			inline = { adapter = "openai_compatible" },
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
			openai_compatible = function()
				local llm = require("plugins.utils.llm")
				local config = llm.get_config()

				return require("codecompanion.adapters").extend("openai_compatible", {
					env = {
						url = config["endpoint"],
					},
					schema = {
						model = {
							default = config["model"],
						},
						num_ctx = {
							-- Ollama specific, currently not working
							default = 16384,
						},
					},
				})
			end,
		},
	},
}
