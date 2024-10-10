local M = {}

--- Change if the current buffer is empty
---@return boolean is_empty If the current buffer is empty
function M.is_buffer_empty()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	return #lines == 1 and lines[1] == ""
end

return M
