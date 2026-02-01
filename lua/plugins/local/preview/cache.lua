---Cache management for preview.nvim
local M = {}

local config = require("plugins.local.preview.config")

---Calculate total size of cache directory in bytes
---@return number Total size in bytes
function M.get_size()
	local cache_dir = config.get("cache").dir
	local total = 0

	local handle = vim.loop.fs_scandir(cache_dir)
	if not handle then
		return 0
	end

	while true do
		local name, type = vim.loop.fs_scandir_next(handle)
		if not name then
			break
		end
		if type == "file" then
			local stat = vim.loop.fs_stat(cache_dir .. "/" .. name)
			if stat then
				total = total + stat.size
			end
		end
	end

	return total
end

---Clean up cache if it exceeds the configured size limit
function M.cleanup_if_needed()
	local cache_cfg = config.get("cache")
	local cache_dir = cache_cfg.dir
	local max_size = cache_cfg.max_size_mb * 1024 * 1024 -- Bytes

	local current_size = M.get_size()
	if current_size > max_size then
		vim.fn.delete(cache_dir, "rf")
		vim.fn.mkdir(cache_dir, "p")
	end
end

---Clear the entire cache
function M.clear()
	local cache_dir = config.get("cache").dir
	vim.fn.delete(cache_dir, "rf")
	vim.fn.mkdir(cache_dir, "p")
end

return M
