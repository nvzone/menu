local function insertafter(arr, after, elem)
	local idx = 1
	for i, v in ipairs(arr) do
		if v.name:find(after) then
			idx = i
			break
		end
	end
	table.insert(arr, idx, elem)
end

---@type MenuItem[]
local items = {

	{
		name = "Format Buffer",
		cmd = function()
			local ok, conform = pcall(require, "conform")

			if ok then
				conform.format({ lsp_fallback = true })
			else
				vim.lsp.buf.format()
			end
		end,
		rtxt = "<leader>fm",
	},

	{
		name = "Code Actions",
		cmd = vim.lsp.buf.code_action,
		rtxt = "<leader>ca",
	},

	{ name = "separator" },

	{
		name = "  Lsp Actions",
		hl = "Exblue",
		items = function()
			return require("menus.lsp")
		end,
	},

	{ name = "separator" },

	{
		name = "Edit Config",
		cmd = function()
			vim.cmd("tabnew")
			local conf = vim.fn.stdpath("config")
			vim.cmd("tcd " .. conf .. " | e init.lua")
		end,
		rtxt = "ed",
	},

	{
		name = "Copy Content",
		cmd = "%y+",
		rtxt = "<C-c>",
	},

	{
		name = "Delete Content",
		cmd = "%d",
		rtxt = "dc",
	},

	{ name = "separator" },

	{
		name = "  Open in terminal",
		hl = "ExRed",
		cmd = function()
			local old_buf = require("menu.state").old_data.buf
			local old_bufname = vim.api.nvim_buf_get_name(old_buf)
			local old_buf_dir = vim.fn.fnamemodify(old_bufname, ":h")

			local cmd = "cd " .. old_buf_dir

			-- base46_cache var is an indicator of nvui user!
			if vim.g.base46_cache then
				require("nvchad.term").new({ cmd = cmd, pos = "sp" })
			else
				vim.cmd("enew")
				vim.fn.termopen({ vim.o.shell, "-c", cmd .. " ; " .. vim.o.shell })
			end
		end,
	},

	{ name = "separator" },

	{
		name = "  Color Picker",
		cmd = function()
			require("minty.huefy").open()
		end,
	},
}

local ok = require("which-key")
if ok then
	insertafter(items, "Lsp Actions", {
		name = "  Which-key",
		hl = "Exblue",
		items = function()
			return require("menus.which-key")
		end,
	})
end

return items
