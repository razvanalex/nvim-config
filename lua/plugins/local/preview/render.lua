---Rendering logic for preview.nvim (PDF and images)
local M = {}

local config = require("plugins.local.preview.config")
local image_utils = require("plugins.local.preview.image")

---@type table<number, table> Buffer-local state storage
M.states = {}

---Create initial state for a buffer
---@param filepath string Path to the file
---@return table
function M.create_state(filepath)
	-- Determine capabilities via image utils
	local needs_conversion = image_utils.is_convertible(filepath)
	local has_pages = image_utils.has_pages(filepath)

	return {
		page = 0,
		zoom = 1.0,
		density = config.get("render").density,
		offset_x = 0,
		offset_y = 0,
		img_width = 0,
		img_height = 0,
		current_image = nil,
		filepath = filepath,
		has_pages = has_pages, -- Treat multi-page docs (like PDF) as having pages logic
		needs_conversion = needs_conversion,
		-- Config-driven
		goto_bottom_on_prev_page = config.get("render").goto_bottom_on_prev_page,
		scroll_step = config.get("render").scroll_step,
		pan_step = config.get("render").pan_step,
		fast_scroll_step = config.get("render").fast_scroll_step,
	}
end

---Resolve effective initial mode from config
---@param mode_cfg string|table Configuration value
---@param has_pages boolean Whether current file has pages
---@return string
local function resolve_mode(mode_cfg, has_pages)
	if type(mode_cfg) == "string" then
		return mode_cfg
	elseif type(mode_cfg) == "table" then
		if has_pages and mode_cfg.pdf then
			return mode_cfg.pdf
		elseif not has_pages and mode_cfg.image then
			return mode_cfg.image
		else
			return mode_cfg.default or "auto"
		end
	end
	return "auto"
end

---Determine base columns based on mode
---@param mode string Resolved mode
---@param state table Buffer state
---@param win_width number Window width
---@param win_height number Window height
---@param cell_w number Terminal cell pixel width
---@param cell_ratio number Terminal cell aspect ratio
---@return number base_cols
local function determine_base_cols(mode, state, win_width, win_height, cell_w, cell_ratio)
	if state.img_width <= 0 then
		return win_width
	end

	local native_cols = math.ceil(state.img_width / cell_w)
	local fit_height_cols = 0
	if state.img_height > 0 then
		-- Aspect ratio preserve: cols = (win_height * img_width * ratio) / img_height
		fit_height_cols = math.floor((win_height * state.img_width * cell_ratio) / state.img_height)
	end

	if mode == "native" then
		return native_cols
	elseif mode == "fit" then
		return win_width
	elseif mode == "fit_height" then
		return fit_height_cols
	elseif mode == "fit_all" then
		return math.min(win_width, fit_height_cols)
	else
		-- "auto"
		if state.has_pages then
			return win_width
		else
			return math.min(win_width, native_cols)
		end
	end
end

---Get geometry calculations for rendering
---@param state table
---@param win_width number Window width in columns
---@param win_height number Window height in rows
---@return table Geometry info
function M.calculate_geometry(state, win_width, win_height)
	-- Configurable logic
	local render_cfg = config.get("render")
	local cell_w = render_cfg.term_cell_width or 10
	local cell_h = render_cfg.term_cell_height or 21
	local cell_ratio = cell_h / cell_w

	local mode_cfg = render_cfg.initial_mode or "auto"

	local mode = resolve_mode(mode_cfg, state.has_pages)

	local base_cols = determine_base_cols(mode, state, win_width, win_height, cell_w, cell_ratio)

	local virt_cols = base_cols * state.zoom
	local px_per_col = state.img_width / virt_cols
	local px_per_row = px_per_col * cell_ratio -- Terminal cells vertical ratio

	local display_width = math.ceil(math.min(win_width, virt_cols))

	local crop_x = math.floor(math.abs(state.offset_x) * px_per_col)
	local crop_y = math.floor(math.abs(state.offset_y) * px_per_row)
	local crop_w = math.floor(display_width * px_per_col)
	local crop_h = math.floor(win_height * px_per_row)

	-- Clamp to image bounds
	crop_x = math.min(crop_x, math.max(0, state.img_width - crop_w))
	crop_y = math.min(crop_y, math.max(0, state.img_height - crop_h))
	crop_w = math.min(crop_w, state.img_width - crop_x)
	crop_h = math.min(crop_h, state.img_height - crop_y)

	local img_rows = state.img_height / px_per_row

	return {
		px_per_col = px_per_col,
		px_per_row = px_per_row,
		crop_x = crop_x,
		crop_y = crop_y,
		crop_w = crop_w,
		crop_h = crop_h,
		img_rows = img_rows,
		display_width = display_width,
	}
end

---Render the current page
---@param bufnr number Buffer number
function M.render(bufnr)
	local state = M.states[bufnr]
	if not state then
		return
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local image_api = require("image")
	local winid = vim.api.nvim_get_current_win()
	local effective_density = math.ceil(state.density * state.zoom)

	-- Callback to render once we have the image path and dimensions
	---@param png_path string Path to image/PNG
	---@param img_w number Image width
	---@param img_h number Image height
	local function do_render(png_path, img_w, img_h)
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end
			if not vim.api.nvim_win_is_valid(winid) then
				return
			end

			state.img_width = img_w
			state.img_height = img_h

			local current_win_width = vim.api.nvim_win_get_width(winid)
			local current_win_height = vim.api.nvim_win_get_height(winid)

			-- Handle pending go-to-bottom (for previous page navigation)
			if state.pending_goto_bottom then
				state.pending_goto_bottom = nil
				local virt_cols = current_win_width * state.zoom
				local px_per_col = img_w / virt_cols
				local px_per_row = px_per_col * 2.1
				local img_rows = img_h / px_per_row
				if img_rows > current_win_height then
					state.offset_y = -(img_rows - current_win_height)
				else
					state.offset_y = 0
				end
			end

			local geom = M.calculate_geometry(state, current_win_width, current_win_height)
			local cropped_path = image_utils.crop_sync(png_path, geom.crop_x, geom.crop_y, geom.crop_w, geom.crop_h)

			-- Setup buffer for image display
			if vim.api.nvim_buf_line_count(bufnr) < 1 then
				vim.bo[bufnr].modifiable = true
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, { "" })
				vim.bo[bufnr].modifiable = false
			end

			local old_image = state.current_image

			if vim.fn.filereadable(cropped_path) ~= 1 then
				return
			end

			local img = image_api.from_file(cropped_path, {
				id = "preview_" .. bufnr .. "_" .. os.time() .. "_" .. math.random(10000),
				window = winid,
				buffer = bufnr,
				with_virtual_padding = true,
				x = 0,
				y = 1,
				width = geom.display_width,
			})

			if img then
				local ok, _ = pcall(function()
					img:render()
				end)
				if ok then
					state.current_image = img
					if old_image then
						pcall(function()
							old_image:clear()
						end)
					end
				end
			end

			M.precache_nearby(bufnr, png_path, current_win_width, current_win_height)
		end)
	end

	-- Route to convertible (PDF/SVG) or native image handler
	if state.needs_conversion then
		if state.has_pages then
			image_utils.convert_pdf_page(state.filepath, state.page, effective_density, do_render)
		else
			-- SVG - convert to PNG first
			image_utils.convert_to_png(state.filepath, function(png_path)
				image_utils.get_dimensions(png_path, function(w, h)
					do_render(png_path, w, h)
				end)
			end)
		end
	else
		-- Native image - just get dimensions and render directly
		image_utils.get_dimensions(state.filepath, function(w, h)
			do_render(state.filepath, w, h)
		end)
	end
end

---Pre-cache crops for nearby scroll positions in all directions
---@param bufnr number Buffer number
---@param png_path string Path to the source PNG
---@param win_width number Window width
---@param win_height number Window height
function M.precache_nearby(bufnr, png_path, win_width, win_height)
	local state = M.states[bufnr]
	if not state or state.img_width == 0 then
		return
	end

	local precache_steps = config.get("cache").precache_steps

	-- Use proper geometry calculation (accounts for initial_mode)
	local geom = M.calculate_geometry(state, win_width, win_height)

	-- Skip scroll pre-caching if image fits entirely in window
	local needs_scroll = state.img_height > geom.crop_h or state.img_width > geom.crop_w
	if needs_scroll then
		-- Current position
		local base_x = math.floor(math.abs(state.offset_x) * geom.px_per_col)
		local base_y = math.floor(math.abs(state.offset_y) * geom.px_per_row)

		-- Step sizes in pixels
		local step_y = math.floor(state.scroll_step * geom.px_per_row)
		local step_x = math.floor(state.pan_step * geom.px_per_col)

		-- Helper to queue a crop if it's within bounds
		local function queue_crop(x, y)
			x = math.max(0, math.min(x, state.img_width - geom.crop_w))
			y = math.max(0, math.min(y, state.img_height - geom.crop_h))

			if x >= 0 and y >= 0 and x + geom.crop_w <= state.img_width and y + geom.crop_h <= state.img_height then
				image_utils.crop_async(png_path, x, y, geom.crop_w, geom.crop_h)
			end
		end

		-- Pre-cache in all 4 directions
		for i = 1, precache_steps do
			queue_crop(base_x, base_y + step_y * i) -- Down
			queue_crop(base_x, base_y - step_y * i) -- Up
			queue_crop(base_x + step_x * i, base_y) -- Right
			queue_crop(base_x - step_x * i, base_y) -- Left
		end
	end

	-- Pre-cache adjacent pages
	if state.has_pages then
		local effective_density = math.ceil(state.density * state.zoom)
		local cache_cfg = config.get("cache")
		local pages_after = cache_cfg.precache_pages_after or 2
		local pages_before = cache_cfg.precache_pages_before or 1

		-- Pre-cache next pages
		for i = 1, pages_after do
			image_utils.convert_pdf_page(state.filepath, state.page + i, effective_density, function() end)
		end

		-- Pre-cache previous pages
		for i = 1, pages_before do
			if state.page - i >= 0 then
				image_utils.convert_pdf_page(state.filepath, state.page - i, effective_density, function() end)
			end
		end
	end
end

---Scroll or navigate pages
---@param bufnr number Buffer number
---@param direction "up"|"down" Direction to scroll/navigate
---@param count number Number of steps
function M.scroll_or_nav(bufnr, direction, count)
	local state = M.states[bufnr]
	if not state or state.img_width == 0 then
		return
	end

	local winid = vim.api.nvim_get_current_win()
	local win_height = vim.api.nvim_win_get_height(winid)
	local win_width = vim.api.nvim_win_get_width(winid)
	local step = state.scroll_step * count

	local geom = M.calculate_geometry(state, win_width, win_height)

	if direction == "down" then
		if geom.img_rows <= win_height then
			-- Image fits in window - for PDFs, go to next page; for images, do nothing
			if state.has_pages then
				state.page = state.page + count
				state.offset_y = 0
				state.offset_x = 0
			end
		else
			local min_y = -(geom.img_rows - win_height)
			if state.offset_y > min_y then
				state.offset_y = math.max(min_y, state.offset_y - step)
			elseif state.has_pages then
				-- At bottom, go to next page
				state.page = state.page + 1
				state.offset_y = 0
				state.offset_x = 0
			end
		end
	elseif direction == "up" then
		if geom.img_rows <= win_height then
			-- Image fits in window - for PDFs, go to prev page; for images, do nothing
			if state.has_pages and state.page > 0 then
				state.page = state.page - count
				if state.goto_bottom_on_prev_page then
					state.pending_goto_bottom = true
				else
					state.offset_y = 0
				end
				state.offset_x = 0
			end
		else
			if state.offset_y < 0 then
				state.offset_y = math.min(0, state.offset_y + step)
			elseif state.has_pages and state.page > 0 then
				-- At top, go to previous page
				state.page = state.page - 1
				if state.goto_bottom_on_prev_page then
					state.pending_goto_bottom = true
				else
					state.offset_y = 0
				end
				state.offset_x = 0
			end
		end
	end

	M.render(bufnr)
end

---Clear the current image for a buffer
---@param bufnr number Buffer number
function M.clear(bufnr)
	local state = M.states[bufnr]
	if state and state.current_image then
		pcall(function()
			state.current_image:clear()
		end)
	end
end

---Clear images for all managed buffers
function M.clear_all()
	for bufnr, state in pairs(M.states) do
		if state.current_image then
			pcall(function()
				state.current_image:clear()
			end)
		end
	end
end

---Render all visible preview buffers
function M.render_all_visible()
	for bufnr, _ in pairs(M.states) do
		if vim.api.nvim_buf_is_valid(bufnr) then
			local wins = vim.fn.win_findbuf(bufnr)
			if #wins > 0 then
				M.render(bufnr)
			end
		end
	end
end

---Pan horizontally
---@param bufnr number Buffer number
---@param direction "left"|"right" Direction to pan
---@param count number Number of steps
function M.pan_horizontal(bufnr, direction, count)
	local state = M.states[bufnr]
	if not state then
		return
	end

	local step = state.pan_step * count
	local win_width = vim.api.nvim_win_get_width(0)
	local virt_cols = win_width * state.zoom
	local min_x = -(virt_cols - win_width)

	if direction == "left" then
		if state.offset_x < 0 then
			state.offset_x = math.min(0, state.offset_x + step)
			M.render(bufnr)
		end
	elseif direction == "right" then
		if state.offset_x > min_x then
			state.offset_x = math.max(min_x, state.offset_x - step)
			M.render(bufnr)
		end
	end
end

---Zoom in or out
---@param bufnr number Buffer number
---@param delta number Zoom delta (positive = zoom in, negative = zoom out)
function M.zoom(bufnr, delta)
	local state = M.states[bufnr]
	if not state then
		return
	end

	local new_zoom = state.zoom + delta
	if new_zoom >= 0.25 then
		state.zoom = new_zoom
		if state.zoom <= 1.0 then
			state.offset_x = 0
			state.offset_y = 0
		end
		M.render(bufnr)
	end
end

---Go to a specific page
---@param bufnr number Buffer number
---@param page number Page number (1-indexed for user, converted to 0-indexed internally)
function M.goto_page(bufnr, page)
	local state = M.states[bufnr]
	if not state then
		return
	end

	state.page = math.max(0, page - 1)
	state.offset_x = 0
	state.offset_y = 0
	M.render(bufnr)
end

---Setup keymaps for a buffer
---@param bufnr number Buffer number
function M.setup_keymaps(bufnr)
	local opts = { buffer = bufnr, noremap = true, silent = true }

	vim.keymap.set("n", "j", function()
		M.scroll_or_nav(bufnr, "down", vim.v.count1)
	end, opts)
	vim.keymap.set("n", "k", function()
		M.scroll_or_nav(bufnr, "up", vim.v.count1)
	end, opts)
	vim.keymap.set("n", "<Down>", function()
		M.scroll_or_nav(bufnr, "down", vim.v.count1)
	end, opts)
	vim.keymap.set("n", "<Up>", function()
		M.scroll_or_nav(bufnr, "up", vim.v.count1)
	end, opts)

	vim.keymap.set("n", "<C-d>", function()
		local s = M.states[bufnr]
		if s then
			M.scroll_or_nav(bufnr, "down", math.ceil(s.fast_scroll_step / s.scroll_step))
		end
	end, opts)
	vim.keymap.set("n", "<C-u>", function()
		local s = M.states[bufnr]
		if s then
			M.scroll_or_nav(bufnr, "up", math.ceil(s.fast_scroll_step / s.scroll_step))
		end
	end, opts)

	vim.keymap.set("n", "h", function()
		M.pan_horizontal(bufnr, "left", vim.v.count1)
	end, opts)
	vim.keymap.set("n", "l", function()
		M.pan_horizontal(bufnr, "right", vim.v.count1)
	end, opts)
	vim.keymap.set("n", "<Left>", function()
		M.pan_horizontal(bufnr, "left", vim.v.count1)
	end, opts)
	vim.keymap.set("n", "<Right>", function()
		M.pan_horizontal(bufnr, "right", vim.v.count1)
	end, opts)

	vim.keymap.set("n", "+", function()
		M.zoom(bufnr, 0.25)
	end, opts)
	vim.keymap.set("n", "-", function()
		M.zoom(bufnr, -0.25)
	end, opts)

	vim.api.nvim_buf_create_user_command(bufnr, "PreviewPage", function(cmd_opts)
		local p = tonumber(cmd_opts.args)
		if p then
			M.goto_page(bufnr, p)
		end
	end, { nargs = 1 })
end

---Setup buffer for preview viewing
---@param bufnr number Buffer number
function M.setup_buffer(bufnr)
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].modifiable = true
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })
	vim.bo[bufnr].modifiable = false

	-- Window-local options
	vim.wo[0].number = false
	vim.wo[0].relativenumber = false
	vim.wo[0].cursorline = false
	vim.wo[0].colorcolumn = ""
	vim.wo[0].signcolumn = "no"
	vim.wo[0].wrap = false
end

---Initialize Preview viewer for a file
---@param bufnr number Buffer number
---@param filepath string Path to the file
function M.init(bufnr, filepath)
	M.setup_buffer(bufnr)
	M.states[bufnr] = M.create_state(filepath)
	M.setup_keymaps(bufnr)
	M.render(bufnr)

	-- File watcher (auto-refresh on external change)
	local uv = vim.uv or vim.loop
	local watcher = uv.new_fs_event()
	if watcher then
		watcher:start(filepath, {}, vim.schedule_wrap(function()
			if M.states[bufnr] then
				M.render(bufnr)
			end
		end))
		M.states[bufnr].watcher = watcher
	end

	-- Cleanup on buffer closing
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = bufnr,
		callback = function()
			local state = M.states[bufnr]
			if state then
				if state.watcher then
					state.watcher:stop()
					state.watcher:close()
				end
				if state.current_image then
					pcall(function() state.current_image:clear() end)
				end
				M.states[bufnr] = nil
			end
		end,
	})
end

return M
