local M = {}

---@alias OnSuccessFun fun()
---@alias OnFailureFun fun(exit_code: number, stderr: string)

--- Format an error message from execution failure.
---@param msg string The base error message.
---@param exit_code integer The exit code of the failed execution.
---@param stderr string? The stderr output from the execution.
---@return string error_msg The formatted error message.
function M.format_error(msg, exit_code, stderr)
	local error_msg = string.format("%s. Execution failed (exit code: %d)", msg, exit_code)
	if stderr and stderr ~= "" then
		error_msg = error_msg .. "\n" .. stderr
	end
	return error_msg
end

--- Create a function that can run only once.
---@param func function The function to be run once.
---@return function once The function to be run once.
function M.exec_once(func)
	local is_init = false

	local once = function()
		if is_init then
			return
		end
		is_init = true
		func()
	end

	return once
end

--- Execute a shell command. This is quite simple, as we don't pass state to callbacks.
---@param cmd string the shell command to execute
---@param opts table? Opts to be passed to jobstart. Note that on_exit and on_stderr cannot be overwritten.
function M.async_exec(cmd, opts)
	if opts == nil then
		opts = {}
	end

	---@param on_success OnSuccessFun The callback on success
	---@param on_failure OnFailureFun The callback on failure with exit code and stderr
	---@return integer retcode The channel-id or failure
	return function(on_success, on_failure)
		local stderr_output = {}

		opts.on_stderr = function(_, data, _)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(stderr_output, line)
					end
				end
			end
		end

		opts.on_exit = function(_, exit_code, _)
			if exit_code == 0 then
				on_success()
			else
				local stderr = table.concat(stderr_output, "\n")
				on_failure(exit_code, stderr)
			end
		end

		return vim.fn.jobstart(cmd, opts)
	end
end

--- Runs a callback after all async functions complete with success.
---@param async_fns function[] The list of async functions to run
---@param on_success function The callback to run when all functions succeed
---@param on_failure function The callback to run if at least one function fails
function M.await_all(async_fns, on_success, on_failure)
	local succeeded = 0
	local all_on_success = function()
		succeeded = succeeded + 1
		if succeeded == #async_fns then
			on_success()
		end
	end

	local failed = 0
	local any_on_failure = function()
		failed = failed + 1
		if failed == 1 then
			on_failure()
		end
	end

	for _, fn in ipairs(async_fns) do
		-- For now, let's treat errors the same as success
		fn(all_on_success, any_on_failure)
	end
end

--- Generates the command to run module inside python environment. Make sure the environment exists.
---@param cmd string The command to be run.
---@param pyenv string? Path to the environment. If not provided, will use the global installation.
---@return string cmd The cmd inside a python module.
function M.pyenv_cmd(cmd, pyenv)
	local python_exec = "python -m "
	if pyenv ~= nil then
		python_exec = pyenv .. "/bin/python -m "
	end
	return python_exec .. cmd
end

--- Create a python venv.
---@param path string Path where to save the venv.
---@param name string The name of the venv.
---@param callback function? Callback to be executed on success or when exists.
---@return string pyenv path/name
function M.create_pyenv(path, name, callback)
	local pyenv = path .. "/" .. name
	local cmd = "mkdir -p " .. path .. " && \
				cd " .. path .. " && \
				python3 -m venv " .. name

	if os.execute("[ -d " .. pyenv .. " ]") ~= 0 then
		local promise = M.async_exec(cmd, { detach = true })
		local job = promise(function()
			vim.notify("Created " .. pyenv, vim.log.levels.INFO)
			if callback ~= nil then
				callback(pyenv)
			end
		end, function(exit_code, stderr)
			vim.notify(M.format_error("Failed to create `" .. pyenv .. "`", exit_code, stderr), vim.log.levels.ERROR)
		end)

		if job <= 0 then
			vim.notify("Failed to execute create env.", vim.log.levels.ERROR)
		end
	else
		if callback ~= nil then
			callback(pyenv)
		end
	end
	return pyenv
end

---@param package string
---@param callback function
local function prompt_installation(package, callback)
	local utils = require("plugins.utils.table")
	local items = {
		["1"] = "Install in current environment",
		["2"] = "Cancel",
	}
	vim.ui.select(utils.keys(items), {
		prompt = "Do you want to install " .. package .. "?",
		format_item = function(item)
			return items[item]
		end,
	}, function(choice)
		if choice == "1" then
			callback()
		end
	end)
end

---@param pkgs string[]
---@param opts PipOptions
local function async_maybe_pip_install(pkgs, opts)
	local to_install = {}
	local promises = {}

	for _, pkg in ipairs(pkgs) do
		local cmd = M.pyenv_cmd("pip freeze | grep " .. pkg, opts.pyenv)
		local promise = M.async_exec(cmd)

		table.insert(promises, function(on_success, _)
			promise(function()
				-- vim.notify("Package `" .. pkg .. "` already installed", vim.log.levels.DEBUG)
				on_success()
			end, function()
				-- vim.notify("Package `" .. pkg .. "` not installed", vim.log.levels.DEBUG)
				table.insert(to_install, pkg)
				on_success()
			end)
		end)
	end

	M.await_all(promises, function()
		if #to_install == 0 then
			if opts.already_installed_cb ~= nil then
				opts.already_installed_cb()
			end
			return
		end

		local pkgs_installed = table.concat(to_install, " ")
		local pkgs_string = table.concat(to_install, ",")
		local cmd = M.pyenv_cmd("pip install " .. pkgs_installed, opts.pyenv)
		local install_exec = function()
			vim.fn.jobstart(cmd, {
				on_exit = function(_, exit_code, _)
					if exit_code ~= 0 then
						vim.notify(
							("Error while installing `" .. pkgs_string .. "`: exit code %s"):format(exit_code),
							vim.log.levels.ERROR
						)
						return
					else
						vim.notify("Packages `" .. pkgs_string .. "` successfully installed", vim.log.levels.INFO)
					end
					if opts.newly_installed_cb ~= nil then
						opts.newly_installed_cb()
					end
				end,
			})
		end

		if opts.prompt_installation == true then
			prompt_installation(pkgs_string, install_exec)
		else
			install_exec()
		end
	end, function() end)
end

---@class PipOptions
---@field newly_installed_cb function? If a callback needs to be run after installation succeeds.
---@field already_installed_cb function? If a callback needs to be run after installation succeeds.
---@field pyenv string? The path to a python environment.
---@field prompt_installation boolean? Whether to prompt the user to install the packages.

--- Install a python package using pip package manager. The installation is async.
---@param pkgs string|string[] The name of the package or list of packages.
---@param opts PipOptions? Options
function M.maybe_pip_install(pkgs, opts)
	if type(pkgs) ~= "table" then
		pkgs = { pkgs }
	end
	if opts == nil then
		opts = {}
	end

	local path = require("path")

	local pyenv = ""
	if opts.pyenv ~= nil then
		---@type string
		pyenv = opts.pyenv
	end

	M.create_pyenv(path.dirname(pyenv), path.basename(pyenv), function()
		local async = require("plenary.async")
		local job = async.void(function()
			async_maybe_pip_install(pkgs, opts)
		end)

		async.run(job, function() end)
	end)
end

return M
