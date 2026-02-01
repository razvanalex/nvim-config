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
			for bufnr, _ in pairs(render.states) do
				if vim.api.nvim_buf_is_valid(bufnr) then
					local wins = vim.fn.win_findbuf(bufnr)
					if #wins > 0 then
						render.render(bufnr)
					end
				end
			end
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
