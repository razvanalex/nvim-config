return {
	{
		"huggingface/llm.nvim",
		event = "VeryLazy",
		opts = {
			model = "starcoder2:1b", -- the model ID, behavior depends on backend
			backend = "ollama", -- backend ID, "huggingface" | "ollama" | "openai" | "tgi"
			url = "http://localhost:11434/api/generate", -- the http url of the backend
			tokens_to_clear = { "<|endoftext|>" }, -- tokens to remove from the model's output
			request_body = {
				parameters = {
					temperature = 0.2,
					top_p = 0.95,
				},
			},
			-- tokenizer = {
			-- 	repository = "bigcode/starcoder2-3b",
			-- 	api_token = nil, -- optional, in case the API token used for the backend is not the same
			-- },
			-- set this if the model supports fill in the middle
			fim = {
				enabled = true,
				prefix = "<fim_prefix>",
				middle = "<fim_middle>",
				suffix = "<fim_suffix>",
			},
			debounce_ms = 150,
			accept_keymap = "<C-Y>",
			dismiss_keymap = "<C-N>",
			context_window = 2048, -- max number of tokens for the context window
			enable_suggestions_on_startup = false,
			enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
		},
	},
	{
		"jackMort/ChatGPT.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"folke/trouble.nvim",
			"nvim-telescope/telescope.nvim",
		},
		event = "VeryLazy",
		config = function()
			local llm_name = "llama2:13b"

			require("chatgpt").setup({
				api_host_cmd = "echo -n http://localhost:11434",
				api_key_cmd = "echo x",
				actions_paths = {
					vim.fn.stdpath("config") .. "/lua/plugins/llm_actions/actions_llama2_13b.json",
				},
				openai_params = {
					model = llm_name,
					frequency_penalty = 0,
					presence_penalty = 0,
					max_tokens = 300,
					temperature = 0,
					top_p = 1,
					n = 1,
				},
				openai_edit_params = {
					model = llm_name,
					frequency_penalty = 0,
					presence_penalty = 0,
					temperature = 0,
					top_p = 1,
					n = 1,
				},
			})
		end,
	},
}
