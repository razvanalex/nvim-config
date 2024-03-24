return { -- manage buffers easier
	"theprimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	cond = not vim.g.vscode,
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup({})

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():append()
		end, { desc = "Harpoon [A]dd Buffer" })
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list(), {
				title_pos = "center",
				---@diagnostic disable-next-line: assign-type-mismatch
				title = { { " Harpoon ", "TelescopePreviewTitle" } },
				border = { { "+", "TelescopePreviewBorder" } },
				ui_max_width = 100,
			})
		end, { desc = "Open Harpoon List" })

		vim.keymap.set("n", "<C-h>", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon Select 1" })
		vim.keymap.set("n", "<C-j>", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon Select 2" })
		vim.keymap.set("n", "<C-k>", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon Select 3" })
		vim.keymap.set("n", "<C-l>", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon Select 4" })

		-- Toggle previous & next buffers stored within Harpoon list
		vim.keymap.set("n", "<C-S-j>", function()
			harpoon:list():prev()
		end, { desc = "Harpoon previous buffer" })
		vim.keymap.set("n", "<C-S-k>", function()
			harpoon:list():next()
		end, { desc = "Harpoon next buffer" })
	end,
}
