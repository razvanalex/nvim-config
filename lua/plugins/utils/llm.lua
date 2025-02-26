local Path = require("plenary.path")
local data_path = vim.fn.stdpath("data")
local config_path = string.format("%s/llm.json", data_path)

---@class LLMConfig
---@field backend string|nil
---@field endpoint string|nil
---@field model string|nil

---@type LLMConfig
local defaults = {
	endpoint = "http://localhost:11434",
	backend = "ollama",
}

local M = {}

--- Get all the available LLMs for a given OpenAI compatible endpoint.
---@param endpoint string endpoint URL
---@param backend string either openai or ollama
---@return string[] llms a list of LLMs
function M.get_available_llms(endpoint, backend)
	local llms = {}
	local api_key = os.getenv("OPENAI_API_KEY") or "x"

	local Job = require("plenary.job")
	local response = Job:new({
		command = "curl",
		args = { endpoint, "-H", "Authorization: Bearer " .. api_key },
	}):sync()

	if response == nil or #response ~= 1 then
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
---@param config LLMConfig
function M.save_config(config)
	Path:new(config_path):write(vim.fn.json_encode(config), "w")
end

--- Load configs for LLMs
---@return LLMConfig, boolean ret the configs and whether the config file is valid
function M.load_config()
	---@type LLMConfig
	local config = {}
	local valid

	valid, config = pcall(function()
		return vim.json.decode(Path:new(config_path):read())
	end)
	if config == nil or (valid and next(config) == nil) then
		valid = false
	end

	if not valid then
		-- Use default configs
		config = {
			-- Model is the first one available or error if no model is installed
			endpoint = os.getenv("NVIM_CHATGPT_ENDPOINT") or defaults["endpoint"],
			backend = os.getenv("NVIM_CHATGPT_BACKEND") or defaults["backend"],
		}
	else
		-- Use endpoint from environment variable. Reset if changed.
		if os.getenv("NVIM_CHATGPT_ENDPOINT") ~= nil then
			config["endpoint"] = os.getenv("NVIM_CHATGPT_ENDPOINT")
		end
		if os.getenv("NVIM_CHATGPT_BACKEND") ~= nil then
			config["backend"] = os.getenv("NVIM_CHATGPT_BACKEND")
		end
	end

	return config, valid
end

--- Get LLM configs
---@return LLMConfig config the config
function M.get_config()
	local config, is_valid = M.load_config()

	local llm_name = M.get_model(config)
	if llm_name == nil then
		return config
	end

	config["model"] = llm_name

	if not is_valid then
		M.save_config(config)
	end

	return config
end

--- Get the endpoint for listing all available models. Currently, it handles ollama (until ollama#2476 is merged) and OpenAI,
---@param config LLMConfig
---@return string endpoint the endpoint
function M.get_models_endpoint(config)
	if config["backend"] == "ollama" then
		return config["endpoint"] .. "/api/tags"
	end

	-- openai default
	return config["endpoint"] .. "/models"
end

--- Show the available LLMs in a telescope view.
---@param config LLMConfig the config
---@param available_llms string[] the list of available LLMs
---@param callback (fun(string): nil)|nil probably reload extensions
function M.toggle_telescope(config, available_llms, callback)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local opts = require("telescope.themes").get_dropdown({})
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- Add (current) to the currently selected LLM
	local llm_list = {}
	local llm_listview = {}
	local current_model = config["model"]
	for _, v in pairs(available_llms) do
		table.insert(llm_list, v)
		if v == current_model then
			v = v .. " (current)"
		end
		table.insert(llm_listview, v)
	end

	-- Show the picker
	pickers
		.new(opts, {
			prompt_title = "Pick LLM",
			finder = finders.new_table({
				results = llm_listview,
			}),
			sorter = conf.generic_sorter(llm_list),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local llm_index = selection.index

					if llm_index ~= nil and llm_index <= #llm_list then
						config["model"] = llm_list[llm_index]
						vim.notify(config["model"] .. " was selected", vim.log.levels.INFO)

						M.save_config(config)

						if callback ~= nil then
							callback(config["model"])
						end
					else
						vim.notify("Invalid model selected", vim.log.levels.ERROR)
					end
				end)
				return true
			end,
		})
		:find()
end

--- Return the currently picked model from the config or the first model available.
---@param config LLMConfig the config
---@return string|nil model_name the name of the model.
function M.get_model(config)
	if config["model"] ~= nil then
		return config["model"]
	end

	local available_llms = M.get_available_llms(M.get_models_endpoint(config), config["backend"])
	if #available_llms >= 1 then
		return available_llms[1]
	end

	vim.notify_once("LLMs: No models available.", vim.log.levels.ERROR)
	return nil
end

return M
