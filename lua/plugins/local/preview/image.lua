---Image utilities for preview.nvim
local M = {}

local config = require("plugins.local.preview.config")

-- Job queue management to limit concurrent processes

---@type number
M.active_jobs = 0
---@type table[]
M.job_queue = {}

---Process the next job in the queue
local function process_queue()
	local job_cfg = config.get("job")
	local max_jobs = (job_cfg and job_cfg.max_jobs) or 4
	if M.active_jobs >= max_jobs or #M.job_queue == 0 then
		return
	end

	local job = table.remove(M.job_queue, 1)
	M.active_jobs = M.active_jobs + 1

	vim.fn.jobstart(job.cmd, {
		stdout_buffered = job.stdout_buffered,
		on_stdout = job.on_stdout,
		on_exit = function(_, code)
			M.active_jobs = M.active_jobs - 1
			if job.on_exit then
				job.on_exit(_, code)
			end
			process_queue() -- Process next job
		end,
	})
end

---Queue a job for execution
---@param job {cmd: string[], stdout_buffered?: boolean, on_stdout?: function, on_exit?: function} Job definition
local function queue_job(job)
	table.insert(M.job_queue, job)
	process_queue()
end

---Check if a file is a native image format (PNG, JPG, etc.)
---@param filepath string
---@return boolean
function M.is_native_image(filepath)
	local ext = filepath:match("%.([^%.]+)$")
	if not ext then
		return false
	end
	ext = ext:lower()
	local native_formats = { "png", "jpg", "jpeg", "gif", "bmp", "webp" }
	for _, fmt in ipairs(native_formats) do
		if ext == fmt then
			return true
		end
	end
	return false
end

---Check if a file can be converted to an image (PDF, etc.)
---@param filepath string
---@return boolean
function M.is_convertible(filepath)
	local ext = filepath:match("%.([^%.]+)$")
	if not ext then
		return false
	end
	ext = ext:lower()
	local convertible_formats = { "pdf", "svg", "eps", "ai" }
	for _, fmt in ipairs(convertible_formats) do
		if ext == fmt then
			return true
		end
	end
	return false
end

---Check if the file has pages
---@param filepath string
---@return boolean
function M.has_pages(filepath)
	local ext = filepath:match("%.([^%.]+)$")
	if not ext then
		return false
	end

	local has_pages_formats = { "pdf" }
	ext = ext:lower()
	for _, fmt in ipairs(has_pages_formats) do
		if ext == fmt then
			return true
		end
	end

	return false
end

---Converts a PDF page to PNG format using ImageMagick
---@param filepath string Path to the PDF file
---@param page number Page number (0-indexed)
---@param density number DPI for rendering
---@param callback function Function called with (png_path, width, height)
function M.convert_pdf_page(filepath, page, density, callback)
	local cache_dir = config.get("cache").dir
	vim.fn.mkdir(cache_dir, "p")

	local stat = vim.loop.fs_stat(filepath)
	local mtime = stat and stat.mtime.sec or 0
	local hash = vim.fn.sha256(filepath .. tostring(mtime) .. tostring(page) .. tostring(density)):sub(1, 16)
	local cached_path = cache_dir .. "/" .. hash .. ".png"

	-- Check cache
	if vim.fn.filereadable(cached_path) == 1 then
		M.get_dimensions(cached_path, function(w, h)
			callback(cached_path, w, h)
		end)
		return
	end

	-- Convert
	local input = filepath .. "[" .. page .. "]"
	local cmd = {
		"magick",
		"-density",
		tostring(density),
		input,
		"-background",
		"white",
		"-flatten",
		cached_path,
	}

	queue_job({
		cmd = cmd,
		on_exit = function(_, code)
			if code == 0 and vim.fn.filereadable(cached_path) == 1 then
				M.get_dimensions(cached_path, function(w, h)
					callback(cached_path, w, h)
				end)
			end
		end,
	})
end

---Get image dimensions
---@param path string Path to image
---@param callback function Called with (width, height)
function M.get_dimensions(path, callback)
	local cmd = { "magick", "identify", "-format", "%w %h", path }
	queue_job({
		cmd = cmd,
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data and data[1] then
				local w, h = data[1]:match("(%d+) (%d+)")
				if w and h then
					callback(tonumber(w), tonumber(h))
				end
			end
		end,
	})
end

---Crop an image synchronously
---@param src_path string Source image path
---@param x number Crop X offset
---@param y number Crop Y offset
---@param w number Crop width
---@param h number Crop height
---@return string Cropped image path
function M.crop_sync(src_path, x, y, w, h)
	local cache_dir = config.get("cache").dir
	local hash = vim.fn.sha256(src_path .. x .. y .. w .. h):sub(1, 16)
	local crop_path = cache_dir .. "/crop_" .. hash .. ".png"

	if vim.fn.filereadable(crop_path) == 1 then
		return crop_path
	end

	local cmd = {
		"magick",
		src_path,
		"-crop",
		string.format("%dx%d+%d+%d", w, h, x, y),
		"+repage",
		crop_path,
	}

	-- Synchronous execution
	vim.fn.jobwait({ vim.fn.jobstart(cmd) }, 2000)

	if vim.fn.filereadable(crop_path) == 1 then
		return crop_path
	end
	return src_path -- Fallback
end

---Crop an image asynchronously (for pre-caching)
---@param src_path string Source image path
---@param x number Crop X offset
---@param y number Crop Y offset
---@param w number Crop width
---@param h number Crop height
---@param callback? function Optional callback when done
function M.crop_async(src_path, x, y, w, h, callback)
	local cache_dir = config.get("cache").dir
	local hash = vim.fn.sha256(src_path .. x .. y .. w .. h):sub(1, 16)
	local crop_path = cache_dir .. "/crop_" .. hash .. ".png"

	-- Already cached
	if vim.fn.filereadable(crop_path) == 1 then
		if callback then
			callback(crop_path)
		end
		return
	end

	local cmd = {
		"magick",
		src_path,
		"-crop",
		string.format("%dx%d+%d+%d", w, h, x, y),
		"+repage",
		crop_path,
	}

	queue_job({
		cmd = cmd,
		on_exit = function(_, code)
			if code == 0 and callback then
				callback(crop_path)
			end
		end,
	})
end

---Converts a file to PNG format using ImageMagick (for generic previews)
---@param filepath string Path to the original file
---@param callback function Function to call with the path to the converted PNG
function M.convert_to_png(filepath, callback)
	local cache_dir = config.get("cache").dir
	local ext = filepath:match("%.([^%.]+)$"):lower()

	local stat = vim.loop.fs_stat(filepath)
	local mtime = stat and stat.mtime.sec or 0
	local hash = vim.fn.sha256(filepath .. tostring(mtime) .. "thumb"):sub(1, 16)
	local cached_path = cache_dir .. "/" .. hash .. ".png"

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

	queue_job({
		cmd = cmd,
		on_exit = function(_, code)
			if code == 0 and vim.fn.filereadable(cached_path) == 1 then
				callback(cached_path)
			end
		end,
	})
end

---Previews an image in the given buffer and window (for telescope)
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

		local width = vim.api.nvim_win_get_width(winid)
		local height = vim.api.nvim_win_get_height(winid)

		local img = image.from_file(filepath, {
			window = winid,
			buffer = bufnr,
			with_virtual_padding = true,
			width = width,
			height = height,
			x = 0,
			y = 0,
		})
		if img then
			img:render()
		end
	end)
end

---Clears images from a specific window
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
