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
		"AvanteRefresh",
		"AvanteShowRepoMap",
		"AvanteSwitchProvider",
		"AvanteToggle",
	},
	keys = function(_, keys)
		---@type avante.Config
		local opts =
			require("lazy.core.plugin").values(require("lazy.core.config").spec.plugins["avante.nvim"], "opts", false)

		local mappings = {
			{
				opts.mappings.ask,
				function()
					require("avante.api").ask()
				end,
				desc = "avante: ask",
				mode = { "n", "v" },
			},
			{
				opts.mappings.edit,
				function()
					require("avante.api").edit()
				end,
				desc = "avante: edit",
				mode = { "n", "v" },
			},
			{
				opts.mappings.refresh,
				function()
					require("avante.api").refresh()
				end,
				desc = "avante: refresh",
				mode = "n",
			},
			{
				opts.mappings.focus,
				function()
					require("avante.api").focus()
				end,
				desc = "avante: focus",
				mode = "n",
			},
			{
				opts.mappings.files.add_current,
				function()
					require("avante.api").focus()
				end,
				desc = "avante: add current buffer to file selector",
				mode = "n",
			},
		}
		mappings = vim.tbl_filter(function(m)
			return m[1] and #m[1] > 0
		end, mappings)
		return vim.list_extend(mappings, keys)
	end,
	opts = {
		provider = "openai", -- Recommend using Claude
		cursor_applying_provider = "fastapply",
		auto_suggestions_provider = "openai",
		openai = {
			temperature = 0,
			max_new_tokens = 16000,
			max_tokens = 16000,
			-- tool_ids = { "web_search" },
			disable_tools = true,
		},
		vendors = {
			fastapply = {
				__inherited_from = "openai",
				api_key_name = "",
				endpoint = "http://localhost:11434/v1",
				model = "qwen2.5-coder:14b",
				max_tokens = 16000,
			},
		},
		behaviour = {
			auto_suggestions = false, -- Experimental stage
			auto_set_highlight_group = true,
			auto_set_keymaps = true,
			auto_apply_diff_after_generation = false,
			support_paste_from_clipboard = false,
			minimize_diff = true,
			enable_token_counting = false,
			enable_cursor_planning_mode = true,
		},
		mappings = {
			--- @class AvanteConflictMappings
			diff = {
				ours = "co",
				theirs = "ct",
				all_theirs = "ca",
				both = "cb",
				cursor = "cc",
				next = "]x",
				prev = "[x",
			},
			suggestion = {
				accept = "<M-y>", -- alt + y
				next = "<M-]>", -- alt + ]
				prev = "<M-[>", -- alt + [
				dismiss = "<M-e>", -- alt + e
			},
			jump = {
				next = "]]",
				prev = "[[",
			},
			submit = {
				normal = "<CR>",
				insert = "<C-s>",
			},
			sidebar = {
				switch_windows = "<Tab>",
				reverse_switch_windows = "<S-Tab>",
			},
			-- Overwrite defaults
			ask = "<leader>aa",
			edit = "<leader>ae",
			refresh = "<leader>ar",
			focus = "<leader>af",
			toggle = {
				default = "<leader>at",
				debug = "<leader>ad",
				hint = "<leader>ah",
				suggestion = "<leader>as",
				repomap = "<leader>aR",
			},
			files = {
				add_current = "<leader>ac", -- Add current buffer to selected files
			},
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
		local llm = require("plugins.utils.llm")
		local cfg = llm.get_config()

		opts.openai.model = cfg["model"]
		opts.openai.endpoint = cfg["endpoint"] .. "/v1/"

		require("avante").setup(opts)
	end,
}
