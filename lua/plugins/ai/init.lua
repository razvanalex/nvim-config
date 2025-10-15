vim.api.nvim_create_user_command("LLMSelectModel", function()
	local llm = require("lua.plugins.utils.llm")

	local config = llm.get_config()
	local endpoint = llm.get_models_endpoint(config)
	local available_llms = llm.get_available_llms(endpoint, config["backend"])

	llm.toggle_telescope(config, available_llms, function()
		vim.cmd(":Lazy reload avante.nvim")
		vim.cmd(":Lazy reload codecompanion.nvim")
	end)
end, {})

return {}
