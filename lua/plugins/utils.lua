local M = {}

--- List all the files, without directories, from the provided directory
---@param dirpath string the path to the directory to be listed
---@param absolute_path boolean whether the output is absolute path or relative to the provided directory
---@return string[] files the list of files from the directory
function M.list_dir(dirpath, absolute_path)
	absolute_path = absolute_path or false
	local files = {}
	for file in io.popen("ls -pa " .. dirpath .. " | grep -v /"):lines() do
		if absolute_path then
			file = dirpath .. "/" .. file
		end
		table.insert(files, file)
	end
	return files
end

return M
