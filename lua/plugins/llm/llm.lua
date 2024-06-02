local data_path = vim.fn.stdpath("data")
local config_path = string.format("%s/llm.json", data_path)
local LLMConfig = {}

--- Get all the available LLMs for a given OpenAI compatible endpoint.
---@param endpoint string endpoint URL
---@param backend string either openai or ollama
---@return string[] llms a list of LLMs
local function get_available_llms(endpoint, backend)
	local llms = {}

	local Job = require("plenary.job")
	local response = Job:new({
		command = "curl",
		args = { endpoint },
	}):sync()

	if #response ~= 1 then
		return llms
	end
	response = response[1]

	local valid, tags = pcall(function()
		return vim.json.decode(response, { object = true, array = true })
	end)
	if not valid or tags == nil then
		return llms
	end
	if backend == "ollama" and tags["models"] ~= nil then
		for _, v in pairs(tags["models"]) do
			table.insert(llms, v["name"])
		end
	elseif backend == "openai" and tags["data"] ~= nil then
		for _, v in pairs(tags["data"]) do
			table.insert(llms, v["id"])
		end
	end
	return llms
end

--- Save the current data to the data path.
local function save_config()
	local Path = require("plenary.path")
	Path:new(config_path):write(vim.fn.json_encode(LLMConfig), "w")

	local settings = require("chatgpt.settings")

	-- Update chat completions model
	settings.type = "chat_completions"
	local completions_settings = settings.read_config()
	if completions_settings ~= nil then
		completions_settings["model"] = LLMConfig["model"]
		settings.write_config(completions_settings)
	end

	-- Update edits model
	settings.type = "edits"
	local edits_settings = settings.read_config()
	if edits_settings ~= nil then
		edits_settings["model"] = LLMConfig["model"]
		settings.write_config(edits_settings)
	end
end

--- Load configs for ChatGPT plugin.
---@return object, boolean ret the configs and whether the config file is valid
local function load_config()
	local Path = require("plenary.path")
	local valid, config = pcall(function()
		return vim.json.decode(Path:new(config_path):read())
	end)

	if config == nil or (valid and next(config) == nil) then
		valid = false
	end
	if not valid then
		-- default configs: ollama
		local endpoint = os.getenv("NVIM_CHATGPT_ENDPOINT") or "http://localhost:11434"
		local backend = os.getenv("NVIM_CHATGPT_BACKEND") or "ollama"

		config = {
			-- model is the first one available or error if no model is installed
			endpoint = endpoint,
			backend = backend,
		}
		return config, valid
	end

	-- Use endpoint from environment variable. Reset if changed.
	if os.getenv("NVIM_CHATGPT_ENDPOINT") ~= nil then
		config["endpoint"] = os.getenv("NVIM_CHATGPT_ENDPOINT")
	end
	if os.getenv("NVIM_CHATGPT_BACKEND") ~= nil then
		config["backend"] = os.getenv("NVIM_CHATGPT_BACKEND")
	end

	return config, valid
end

--- Get the endpoint for listing all available models. Currently, it handles ollama (until ollama#2476 is merged) and OpenAI,
---@return string endpoint the endpoint
local function get_models_endpoint()
	if LLMConfig["backend"] == "ollama" then
		return LLMConfig["endpoint"] .. "/api/tags"
	end
	-- openai default
	return LLMConfig["endpoint"] .. "/v1/models"
end

--- Show the available LLMs in a telescope view.
---@param available_llms string[] the list of available LLMs
local function toggle_telescope(available_llms)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local opts = require("telescope.themes").get_dropdown({})
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- Add (current) to the currently selected LLM
	local llm_list = {}
	local current_model = LLMConfig["model"]
	for _, v in pairs(available_llms) do
		if v == current_model then
			v = v .. " (current)"
		end
		table.insert(llm_list, v)
	end

	-- Show the picker
	pickers
		.new(opts, {
			prompt_title = "Pick LLM",
			finder = finders.new_table({
				results = llm_list,
			}),
			sorter = conf.generic_sorter(llm_list),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					LLMConfig["model"] = selection[1]
					save_config()
					require("lazy.core.loader").reload("ChatGPT.nvim")
				end)
				return true
			end,
		})
		:find()
end

--- Return the currently picked model from the config or the first model available.
---@param backend string either openai or ollama
---@return string model_name the name of the model.
local function get_model(backend)
	if LLMConfig["model"] ~= nil then
		return LLMConfig["model"]
	end

	local available_llms = get_available_llms(get_models_endpoint(), backend)
	if #available_llms >= 1 then
		return available_llms[1]
	end

	error("No models available. Please install at least one.")
end

return {
	{
		"huggingface/llm.nvim",
		cond = not vim.g.vscode,
		event = "InsertEnter",
		cmd = {
			"LLMSuggestion",
			"LLMToggleAutoSuggest",
		},
		opts = {
			model = "starcoder2:3b", -- the model ID, behavior depends on backend
			backend = "ollama", -- backend ID, "huggingface" | "ollama" | "openai" | "tgi"
			url = "http://localhost:11434/api/generate", -- the http url of the backend
			tokens_to_clear = { "<|endoftext|>" }, -- tokens to remove from the model's output
			request_body = {
				parameters = {
					max_new_tokens = 100,
					temperature = 0.2,
					top_p = 0.95,
				},
			},
			tokenizer = {
				repository = "bigcode/starcoder2-3b",
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
			context_window = 4096, -- max number of tokens for the context window
			enable_suggestions_on_startup = false,
			enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
		},
	},
	{
		"jackMort/ChatGPT.nvim",
		cond = not vim.g.vscode,
		cmd = {
			"ChatGPT",
			"ChatGPTActAs",
			"ChatGPTCompleteCode",
			"ChatGPTEditWithInstructions",
			"ChatGPTRun",
			"ChatGPTSelectModel",
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"folke/trouble.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			local NuiText = require("nui.text")
			local valid

			LLMConfig, valid = load_config()
			local llm_name = get_model(LLMConfig["backend"])
			local actions_dir = vim.fn.stdpath("config") .. "/lua/plugins/llm/llm_actions"
			local actions_path = require("plugins.utils.path").list_dir(actions_dir, true)

			if not valid then
				LLMConfig["model"] = llm_name
				save_config()
			end

			vim.api.nvim_create_user_command("ChatGPTSelectModel", function()
				local available_llms = get_available_llms(get_models_endpoint(), LLMConfig["backend"])
				toggle_telescope(available_llms)
			end, {})

			require("chatgpt").setup({
				api_host_cmd = "echo -n " .. LLMConfig["endpoint"],
				api_key_cmd = "echo x",
				actions_paths = actions_path,
				openai_params = {
					model = llm_name,
					frequency_penalty = 0,
					presence_penalty = 0,
					max_tokens = 500,
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
				chat = {
					sessions_window = {
						active_sign = "  ",
						inactive_sign = "  ",
						current_line_sign = "",
						border = {
							highlight = "TelescopePreviewBorder",
							text = {
								top = NuiText(" Sessions ", "TelescopePreviewTitle"),
							},
						},
						win_options = {
							winhighlight = "Normal:TelescopePreviewNormal,FloatBorder:FloatBorder",
						},
					},
				},
				popup_window = {
					border = {
						highlight = "TelescopePreviewBorder",
						text = {
							top = NuiText(" ChatGPT (" .. llm_name .. ") ", "TelescopeResultsTitle"),
						},
					},
					win_options = {
						winhighlight = "Normal:TelescopePreviewNormal",
					},
				},
				system_window = {
					border = {
						highlight = "TelescopePromptBorder",
						text = {
							top = NuiText(" SYSTEM ", "TelescopePromptTitle"),
						},
					},
					win_options = {
						winhighlight = "Normal:TelescopePromptNormal,FloatBorder:FloatBorder",
					},
				},
				popup_input = {
					border = {
						highlight = "TelescopePromptBorder",
						text = {
							top = NuiText(" Prompt ", "TelescopePromptTitle"),
						},
					},
					win_options = {
						winhighlight = "Normal:TelescopePromptNormal,FloatBorder:FloatBorder",
					},
				},
				settings_window = {
					border = {
						highlight = "TelescopePreviewBorder",
						text = {
							top = NuiText(" Settings ", "TelescopePreviewTitle"),
						},
					},
					win_options = {
						winhighlight = "Normal:TelescopePreviewNormal,FloatBorder:FloatBorder",
					},
				},
				help_window = {
					border = {
						highlight = "TelescopePreviewBorder",
						text = {
							top = NuiText(" Help ", "TelescopePreviewTitle"),
						},
					},
					win_options = {
						winhighlight = "Normal:TelescopePreviewNormal,FloatBorder:FloatBorder",
					},
				},
			})
		end,
	},
}
