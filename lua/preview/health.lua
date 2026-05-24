local M = {}

local config = require("plugins.local.preview.config")

local function get_health()
	local health = vim.health or require("health")
	return {
		start = health.start or health.report_start,
		ok = health.ok or health.report_ok,
		warn = health.warn or health.report_warn,
		error = health.error or health.report_error,
	}
end

local function check_executable(health, name, hint)
	if vim.fn.executable(name) == 1 then
		health.ok(name .. " found")
		return true
	end
	local msg = name .. " not found in PATH"
	if hint then
		msg = msg .. ". " .. hint
	end
	health.error(msg)
	return false
end

local function check_cache_dir(health)
	local cache_dir = config.get("cache").dir
	local uv = vim.uv or vim.loop
	local stat = uv.fs_stat(cache_dir)
	if not stat then
		health.warn("cache dir does not exist: " .. cache_dir)
		return
	end
	if stat.type ~= "directory" then
		health.error("cache dir is not a directory: " .. cache_dir)
		return
	end

	if uv.fs_access then
		if uv.fs_access(cache_dir, "W") then
			health.ok("cache dir writable: " .. cache_dir)
		else
			health.warn("cache dir not writable: " .. cache_dir)
		end
	else
		health.ok("cache dir exists: " .. cache_dir)
	end
end

local function check_image_module(health)
	local ok, _ = pcall(require, "image")
	if ok then
		health.ok("image.nvim module is available")
	else
		health.warn("image.nvim module not found (preview will not render images)")
	end
end

local function check_tmux(health)
	if not vim.env.TMUX or vim.env.TMUX == "" then
		health.ok("tmux not detected")
		return
	end

	local output = vim.fn.systemlist({ "tmux", "show-options", "-gqv", "allow-passthrough" })
	local value = output[1] or ""
	if value == "on" then
		health.ok("tmux allow-passthrough is on")
	else
		health.warn("tmux detected; consider: tmux set -g allow-passthrough on")
	end
end

function M.check()
	local health = get_health()

	health.start("preview.nvim")

	check_executable(health, "magick", "Install ImageMagick for PDF/SVG rendering")
	check_image_module(health)
	check_cache_dir(health)
	check_tmux(health)
end

return M
