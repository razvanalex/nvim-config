return {
	"yetone/avante.nvim",
	cond = not vim.g.vscode,
	lazy = true,
	cmd = {
		"AvanteAsk",
		"AvanteBuild",
		"AvanteChat",
		"AvanteClear",
		"AvanteEdit",
		"AvanteFocus",
		"AvanteHistory",
		"AvanteModels",
		"AvanteRefresh",
		"AvanteShowRepoMap",
		"AvanteSwitchFileSelectorProvider",
		"AvanteSwitchProvider",
		"AvanteToggle",
	},
	keys = {
		{
			"<leader>aa",
			function()
				require("avante.api").ask()
			end,
			desc = "avante: ask",
			mode = { "n", "v" },
		},
		{
			"<leader>ae",
			function()
				require("avante.api").edit()
			end,
			desc = "avante: edit",
			mode = { "n", "v" },
		},
	},
	opts = {
		provider = "copilot",
		auto_suggestions_provider = nil,
		cursor_applying_provider = nil,
		copilot = {
			endpoint = "https://api.githubcopilot.com",
			model = "claude-3.7-sonnet",
			proxy = nil, -- [protocol://]host[:port] Use this proxy
			allow_insecure = false, -- Allow insecure server connections
			timeout = 30000, -- Timeout in milliseconds
			temperature = 0,
			max_tokens = 20480,
		},
		behaviour = {
			auto_suggestions = false, -- Experimental stage
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			support_paste_from_clipboard = false,
			minimize_diff = true,
			enable_token_counting = true,
			enable_cursor_planning_mode = false,
			enable_claude_text_editor_tool_mode = false,
		},
		hints = { enabled = false },
		windows = {
			sidebar_header = {
				rounded = false,
			},
		},
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-telescope/telescope.nvim",
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
			},
		},
	},
	config = function(_, opts)
		if opts.vendors ~= nil then
			local llm = require("plugins.utils.llm")
			local cfg = llm.get_config()

			opts.vendors.openai.model = cfg["model"]
			opts.vendors.openai.endpoint = cfg["endpoint"] .. "/v1/"
		end

		require("avante").setup(opts)
	end,
}
