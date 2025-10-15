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
		{ "<leader>cc", ":CodeCompanionChat Add<CR>", desc = "Open [C]odeCompanion [C]hat", mode = "v" },
		{ "<leader>cc", ":CodeCompanionChat Toggle<CR>", desc = "Open [C]odeCompanion [C]hat", mode = "n" },
		{ "<leader>ca", ":CodeCompanionActions<CR>", desc = "Open [C]odeCompanion [A]ctions", mode = "n" },
	},
	opts = {
		--Refer to: https://github.com/olimorris/codecompanion.nvim/blob/main/lua/codecompanion/config.lua
		strategies = {
			agent = { adapter = "copilot" },
			chat = { adapter = "copilot" },
			inline = { adapter = "copilot" },
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
	init = function()
		local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

		vim.api.nvim_create_autocmd({ "User" }, {
			pattern = "CodeCompanionRequestStreaming",
			group = group,
			callback = function(request)
				vim.treesitter.stop(request.buf)
			end,
		})

		vim.api.nvim_create_autocmd({ "User" }, {
			pattern = "CodeCompanionRequestFinished",
			group = group,
			callback = function(request)
				vim.treesitter.start(request.buf)
			end,
		})
	end,
}
