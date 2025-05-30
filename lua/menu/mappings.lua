local utils = require "menu.utils"
local map = vim.keymap.set
local state = require "menu.state"

local M = {}

M.actions = function(items, buf)
  local tb = vim.tbl_filter(function(v)
    return v.rtxt and v.cmd
  end, items)

  for _, v in ipairs(tb) do
    local action = function()
      require("volt").close()

      if type(v.cmd) == "string" then
        vim.cmd(v.cmd)
      else
        v.cmd()
      end
    end

    map("n", v.rtxt, action, { buffer = buf })
  end

  local nested_menus = vim.tbl_filter(function(v)
    return v.items
  end, items)

  for _, v in ipairs(nested_menus) do
    if v.keybind then
      map("n", v.keybind, function()
        vim.api.nvim_win_set_cursor(0, { vim.fn.index(items, v) + 1, 0 })
        utils.toggle_nested_menu(v.name, v.items)
      end, { buffer = buf })
    end
  end
end

M.nav_win = function()
  for _, v in ipairs(vim.tbl_keys(state.bufs)) do
    map("n", "h", function()
      utils.switch_win(-1)
    end, { buffer = v })

    map("n", "l", function()
      utils.switch_win(1)
    end, { buffer = v })
  end
end

M.auto_close = function()
  -- clear menu if clicked outside
  vim.keymap.set("n", "<LeftMouse>", function()
    vim.cmd.exec '"normal! \\<LeftMouse>"'
    local bufid = vim.api.nvim_win_get_buf(vim.fn.getmousepos().winid)
    local menu_buf = state.bufids[1]

    if menu_buf and vim.bo[bufid].ft ~= "NvMenu" then
      vim.api.nvim_buf_call(menu_buf, function()
        vim.api.nvim_feedkeys("q", "x", false)
      end)

      vim.keymap.del("n", "<LeftMouse>")
    end
  end)
end

return M
