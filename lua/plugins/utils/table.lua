local M = {}

--- Get the keys of a table
---@param t table The table with keys
---@return any[] keys The list of keys
function M.keys(t)
	local keys = {}
	for key, _ in pairs(t) do
		table.insert(keys, key)
	end
	return keys
end

return M
