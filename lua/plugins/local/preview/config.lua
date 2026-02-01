---@class PreviewRenderConfig
---@field density number DPI for PDF rendering
---@field scroll_step number Vertical scroll step for j/k
---@field pan_step number Horizontal pan step for h/l
---@field fast_scroll_step number Fast scroll step for C-d/C-u
---@field goto_bottom_on_prev_page boolean Start at bottom when going to previous page
---@alias PreviewMode "fit"|"native"|"auto"|"fit_height"|"fit_all"
---@field term_cell_width number Width of a terminal cell in pixels
---@field term_cell_height number Height of a terminal cell in pixels
---@field initial_mode PreviewMode|table<string, PreviewMode> Initial zoom mode. Can be a string (global) or table (e.g. { default="fit", pdf="fit", image="auto" })

---@class PreviewCacheConfig
---@field dir string Cache directory for converted images
---@field max_size_mb number Max cache size in MB
---@field precache_steps number Steps to precache per direction (scrolling)
---@field precache_pages_before number Pages to precache before current
---@field precache_pages_after number Pages to precache after current

---@class PreviewJobConfig
---@field max_jobs number Max concurrent jobs

---@class PreviewConfig
---@field patterns string[] List of file patterns to handle
---@field render PreviewRenderConfig
---@field job PreviewJobConfig
---@field cache PreviewCacheConfig

local M = {}

---@type PreviewConfig
M.defaults = {
	-- File patterns to associate with this plugin
	patterns = { "*.pdf", "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.svg" },
	render = {
		density = 300, -- Rendering DPI for PDFs (higher = better quality, slower)

		-- Navigation Steps
		scroll_step = 2, -- Rows to scroll per j/k
		pan_step = 4, -- Columns to scroll per h/l
		fast_scroll_step = 20, -- Rows to scroll per C-d/C-u

		goto_bottom_on_prev_page = true, -- When going to previous page, start at bottom (reading flow)

		-- Terminal Font Metris (Calibrate these for 1:1 scaling)
		term_cell_width = 10, -- Pixel width of one terminal cell
		term_cell_height = 21, -- Pixel height of one terminal cell hiding

		-- Initial Zoom/View Mode
		-- Options: "fit" (width), "fit_height", "fit_all" (contain), "native" (1:1), "auto" (smart)
		initial_mode = {
			default = "auto", -- Fallback
			pdf = "fit_all", -- PDFs usually look best fitted to screen
			image = "auto", -- Native for small images, fit for large
		},
	},
	job = {
		max_jobs = 4, -- Limit concurrent ImageMagick processes to prevent CPU spike
	},
	cache = {
		dir = vim.fn.stdpath("cache") .. "/preview", -- Location for converted PNGs
		max_size_mb = 100, -- Maximum cache size before auto-cleanup

		-- Pre-caching Strategy (Optimizes perceived performance)
		precache_steps = 6, -- Number of scroll steps to render ahead (up/down/left/right)
		precache_pages_before = 3, -- Number of previous pages to keep ready
		precache_pages_after = 3, -- Number of future pages to pre-convert
	},
}

---@type PreviewConfig
M.options = {}

---Set configuration options
---@param opts? PreviewConfig User options to merge with defaults
function M.set(opts)
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
	vim.fn.mkdir(M.options.cache.dir, "p")
end

---Get a configuration option
---@param key string Option key
---@return any
function M.get(key)
	return M.options[key]
end

return M
