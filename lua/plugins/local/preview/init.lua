---preview.nvim - PDF viewer for Neovim
---@class PreviewPlugin
local M = {}

local config = require("plugins.local.preview.config")
local cache = require("plugins.local.preview.cache")
local render = require("plugins.local.preview.render")

---Setup the plugin with user options
---@param opts? PreviewConfig User configuration options
function M.setup(opts)
	config.set(opts)
	cache.cleanup_if_needed()

	-- Re-render on window resize
	vim.api.nvim_create_autocmd("WinResized", {
		callback = function()
			render.render_all_visible()
		end,
	})

	-- Supported file patterns
	local patterns = config.get("patterns")

	-- Trigger preview on file open
	vim.api.nvim_create_autocmd("BufReadPost", {
		pattern = patterns,
		callback = function(ev)
			render.init(ev.buf, ev.file)
		end,
	})

	-- Re-render when returning to a preview buffer
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = patterns,
		callback = function(ev)
			if render.states[ev.buf] then
				render.render(ev.buf)
			end
		end,
	})

	-- Restore all visible previews when gaining focus
	vim.api.nvim_create_autocmd("FocusGained", {
		callback = function()
			render.render_all_visible()
		end,
	})

	-- Clear ALL images when losing focus or switching tabs
	vim.api.nvim_create_autocmd({ "TabLeave", "FocusLost" }, {
		callback = function()
			render.clear_all()
		end,
	})

	-- Clear specific buffer image when hidden
	vim.api.nvim_create_autocmd("BufHidden", {
		pattern = patterns,
		callback = function(ev)
			if render.states[ev.buf] then
				render.clear(ev.buf)
			end
		end,
	})

	-- Manual clear command for troubleshooting
	vim.api.nvim_create_user_command("PreviewClear", function()
		render.clear_all()
	end, {})
end

-- Expose modules for external use
M.render = render.render
M.scroll_or_nav = render.scroll_or_nav
M.pan_horizontal = render.pan_horizontal
M.zoom = render.zoom
M.goto_page = render.goto_page
M.states = render.states
M.cache = cache

-- Lazy.nvim plugin spec
return {
	dir = vim.fn.stdpath("config") .. "/lua/plugins/local/preview",
	name = "preview.nvim",
	config = function(_, opts)
		M.setup(opts)
	end,
	opts = {},
}
