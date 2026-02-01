local M = {}
M.cache_dir = vim.fn.stdpath("cache") .. "/image_previews"

local native_image_exts = { "png", "jpg", "jpeg", "gif", "webp", "avif", "bmp", "tiff", "tif", "ico", "heic" }
local convertible_exts = { "svg", "pdf" }

-- Clean up the image preview cache directory on exit
vim.api.nvim_create_autocmd("ExitPre", {
	callback = function()
		vim.fn.delete(M.cache_dir, "rf")
	end,
})

---Extracts the file extension from a given path
---@param path string Path to the file
---@return string|nil The file extension in lowercase, or nil if none found
function M.get_file_extension(path)
	return path:lower():match("%.([^%.]+)$")
end

---Determines if the file is a native image format
---@param filepath string Path to the file
---@return boolean True if native image format, false otherwise
function M.is_native_image(filepath)
	local ext = M.get_file_extension(filepath)
	for _, e in ipairs(native_image_exts) do
		if ext == e then
			return true
		end
	end
	return false
end

---Determines if the file is a convertible image format
---@param filepath string Path to the file
---@return boolean True if convertible image format, false otherwise
function M.is_convertible(filepath)
	local ext = M.get_file_extension(filepath)
	for _, e in ipairs(convertible_exts) do
		if ext == e then
			return true
		end
	end
	return false
end

---Converts an image file to PNG format using ImageMagick
---@param filepath string Path to the original file
---@param callback function Function to call with the path to the converted PNG
function M.convert_to_png(filepath, callback)
	local ext = M.get_file_extension(filepath)
	vim.fn.mkdir(M.cache_dir, "p")

	local stat = vim.loop.fs_stat(filepath)
	local mtime = stat and stat.mtime.sec or 0
	local hash = vim.fn.sha256(filepath .. tostring(mtime)):sub(1, 16)
	local cached_path = M.cache_dir .. "/" .. hash .. ".png"

	if vim.fn.filereadable(cached_path) == 1 then
		callback(cached_path)
		return
	end

	local input = filepath
	if ext == "pdf" then
		input = filepath .. "[0]" -- First page only for PDFs
	end

	local cmd = {
		"magick",
		"-density",
		"150",
		input,
		"-background",
		"white",
		"-flatten",
		"-resize",
		"1600x1600>",
		cached_path,
	}

	vim.fn.jobstart(cmd, {
		on_exit = function(_, code)
			if code == 0 and vim.fn.filereadable(cached_path) == 1 then
				callback(cached_path)
			end
		end,
	})
end

---Previews an image in the given buffer and window
---@param filepath string Path to the image file
---@param bufnr number Buffer number to render the image in
---@param winid number Window ID where the image will be displayed
function M.preview_image(filepath, bufnr, winid)
	local ok, image = pcall(require, "image")
	if not ok then
		return
	end

	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_win_is_valid(winid) then
			return
		end

		local win_width = vim.api.nvim_win_get_width(winid)
		local win_height = vim.api.nvim_win_get_height(winid)

		local img = image.from_file(filepath, {
			window = winid,
			buffer = bufnr,
			with_virtual_padding = true,
			width = win_width,
			height = win_height,
		})
		if img then
			img:render()
		end
	end)
end

---Clears images from a specific window or all images if no window specified
---@param winid? number Optional window ID to clear images from
function M.clear_images(winid)
	local ok, image = pcall(require, "image")
	if not ok then
		return
	end

	local imgs = image.get_images(winid and { window = winid } or nil)
	for _, img in ipairs(imgs) do
		img:clear()
	end
end

return M
