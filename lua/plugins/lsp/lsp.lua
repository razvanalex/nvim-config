return {
	{
		"folke/neodev.nvim",
		lazy = true,
		opts = {},
	},
	{ -- shows issues in code (like Problems in vscode)
		"folke/trouble.nvim",
		cond = not vim.g.vscode,
		event = "VeryLazy",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		opts = {
			signs = {
				error = "",
				warning = "",
				hint = "",
				information = "",
				other = "",
			},
		},
		init = function()
			vim.keymap.set("n", "<leader>tt", function()
				require("trouble").toggle()
			end, { silent = true, noremap = true, desc = "[T]rouble [T]oggle" })

			vim.keymap.set("n", "<leader>tw", function()
				require("trouble").toggle("workspace_diagnostics")
			end, { silent = true, noremap = true, desc = "[T]rouble [W]orkspace Diagnostics" })

			vim.keymap.set("n", "<leader>td", function()
				require("trouble").toggle("document_diagnostics")
			end, { silent = true, noremap = true, desc = "[T]rouble [D]ocument Diagnostics" })

			vim.keymap.set("n", "<leader>tq", function()
				require("trouble").toggle("quickfix")
			end, { silent = true, noremap = true, desc = "[T]rouble [Q]uickfix" })

			vim.keymap.set("n", "<leader>tl", function()
				require("trouble").toggle("loclist")
			end, { silent = true, noremap = true, desc = "[T]rouble [L]oclist" })

			vim.keymap.set("n", "]t", function()
				require("trouble").next({ skip_groups = true, jump = true })
			end, { silent = true, noremap = true, desc = "[T]rouble Next" })

			vim.keymap.set("n", "[t", function()
				require("trouble").previous({ skip_groups = true, jump = true })
			end, { silent = true, noremap = true, desc = "[T]rouble Previous" })
		end,
	},
	{
		"neovim/nvim-lspconfig",
		cond = not vim.g.vscode,
		event = "VeryLazy",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for neovim
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", event = "VeryLazy", opts = {} },
		},
		config = function()
			vim.diagnostic.config({
				virtual_text = false,
			})

			-- init neodev
			require("neodev").setup({})
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			})

			-- lsp theming
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "single",
			})
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "single",
				focusable = true,
				relative = "cursor",
				silent = true,
			})

			-- attach
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, remap = false, desc = "LSP: " .. desc })
					end
					local imap = function(keys, func, desc)
						vim.keymap.set("i", keys, func, { buffer = event.buf, remap = false, desc = "LSP: " .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-T>.
					map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

					--  For example, in C this would take you to the header
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("go", vim.lsp.buf.type_definition, "[G]oto Type [O]bject Definition")

					-- Find references for the word under your cursor.
					map("gr", vim.lsp.buf.references, "[G]oto [R]eferences")

					-- Show signature help
					imap("<C-h>", vim.lsp.buf.signature_help, "Signature [H]elp")

					-- Rename the variable under your cursor
					--  Most Language Servers support renaming across files, etc.
					map("<F2>", vim.lsp.buf.rename, "Rename Symbol")

					-- Format current buffer by calling the formatter
					map("<F3>", vim.lsp.buf.format, "Format Current Buffer")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<F4>", vim.lsp.buf.code_action, "Code Action")

					-- Show the diagnostics
					map("gl", vim.diagnostic.open_float, "Show Diagnostics")

					-- Next diagnostics
					map("[d", vim.diagnostic.goto_next, "Next Diagnostic")

					-- Next diagnostics
					map("]d", vim.diagnostic.goto_prev, "Next Diagnostic")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("gs", vim.lsp.buf.document_symbol, "Show All Document [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace
					--  Similar to document symbols, except searches over your whole project.
					map("gw", vim.lsp.buf.workspace_symbol, "Show [W]orkspace Symbols")

					-- Opens a popup that displays documentation about the word under your cursor
					--  See `:help K` for why this keymap
					map("K", vim.lsp.buf.hover, "Hover Documentation")

					-- Diagnostic icons
					local symbols = { Error = "󰅙", Info = "󰋼", Hint = "󰌵", Warn = "" }

					for name, icon in pairs(symbols) do
						local hl = "DiagnosticSign" .. name
						vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
					end

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.documentHighlightProvider then
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP Specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				clangd = {
					keys = {
						{ "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
					},
					root_dir = function(fname)
						return require("lspconfig.util").root_pattern(
							"Makefile",
							"configure.ac",
							"configure.in",
							"config.h.in",
							"meson.build",
							"meson_options.txt",
							"build.ninja"
						)(fname) or require("lspconfig.util").root_pattern(
							"compile_commands.json",
							"compile_flags.txt"
						)(fname) or require("lspconfig.util").find_git_ancestor(fname)
					end,
					capabilities = {
						offsetEncoding = { "utf-16" },
					},
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
					init_options = {
						usePlaceholders = true,
						completeUnimported = true,
						clangdFileStatus = true,
					},
				},
				gopls = {
					settings = {
						gopls = {
							analyses = {
								unusedparams = true,
							},
							staticcheck = true,
							gofumpt = true,
						},
					},
				},
				-- pyright = {},
				-- rust_analyzer = {},
				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`tsserver`) will work just fine
				-- tsserver = {},
				--

				lua_ls = {
					-- cmd = {...},
					-- filetypes { ...},
					-- capabilities = {},
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
								-- Tells lua_ls where to find all the Lua files that you have loaded
								-- for your neovim configuration.
								library = {
									"${3rd}/luv/library",
									unpack(vim.api.nvim_get_runtime_file("", true)),
								},
								-- If lua_ls is really slow on your computer, you can try this instead:
								-- library = { vim.env.VIMRUNTIME },
							},
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu
			require("mason").setup()

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				ensure_installed = { "basedpyright", "lua_ls" },
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for tsserver)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
	{ -- Show function signature
		"ray-x/lsp_signature.nvim",
		cond = not vim.g.vscode,
		event = "VeryLazy",
		opts = {
			close_timeout = 1000,
			hint_enable = false,
			toggle_key = "<C-k>",
			toggle_key_flip_floatwin_setting = true,
			handler_opts = {
				border = "single", -- double, rounded, single, shadow, none, or a table of borders
			},
		},
		config = function(_, opts)
			require("lsp_signature").setup(opts)

			vim.keymap.set({ "n" }, "<leader>k", function()
				require("lsp_signature").toggle_float_win()
			end, { silent = true, noremap = true, desc = "LSP: Toggle Signature" })
		end,
	},
	{ -- auto-generate docstrings
		"danymat/neogen",
		cmd = "Neogen",
		opts = {
			snippet_engine = "luasnip",
		},
		lazy = true,
		keys = {
			{
				"<leader>nf",
				function()
					require("neogen").generate({ type = "func" })
				end,
				desc = "[N]eogen [F]unction",
			},
			{
				"<leader>nt",
				function()
					require("neogen").generate({ type = "type" })
				end,
				desc = "[N]eogen [T]ype",
			},
			{
				"<leader>nc",
				function()
					require("neogen").generate({ type = "class" })
				end,
				desc = "[N]eogen [C]lass",
			},
			{
				"<leader>ni",
				function()
					require("neogen").generate({ type = "file" })
				end,
				desc = "[N]eogen F[i]le",
			},
		},
	},
}
