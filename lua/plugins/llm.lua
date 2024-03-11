-- TODO:  
local llm = require("llm")

llm.setup({
	model = "starcoder2:15b", -- the model ID, behavior depends on backend
	backend = "ollama", -- backend ID, "huggingface" | "ollama" | "openai" | "tgi"
	url = "http://localhost:11434/api/generate", -- the http url of the backend
	tokens_to_clear = { "<|endoftext|>" }, -- tokens to remove from the model's output
	request_body = {
		parameters = {
			temperature = 0.2,
			top_p = 0.95,
		},
	},
	tokenizer = {
		repository = "bigcode/starcoder2-15b",
		api_token = nil, -- optional, in case the API token used for the backend is not the same
	},
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
	-- tls_skip_verify_insecure = false,
	-- llm-ls configuration, cf llm-ls section
	-- lsp = {
	-- 	bin_path = nil,
	-- 	host = nil,
	-- 	port = nil,
	-- 	version = "0.5.2",
	-- },
	context_window = 8192, -- max number of tokens for the context window
	enable_suggestions_on_startup = false,
	enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
})
