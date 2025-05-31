local M = {}
local api = vim.api
local fn = vim.fn
local state = require "menu.state"

M.get_width = function(tb)
  local w = 0

  for _, value in ipairs(tb) do
    local label = (value.name or "") .. (value.rtxt or "")
    local strlen = fn.strwidth(label)

    if strlen > w then
      w = strlen
    end
  end

  return w
end

local get_bufi = function(bufnr)
  for i, buf in ipairs(state.bufids) do
    if buf == bufnr then
      return i
    end
  end
end

M.adjacent_bufs = function()
  local config = state.config
  local cur_win = (config.mouse and fn.getmousepos().winid) or api.nvim_get_current_win()
  local cur_buf = api.nvim_win_get_buf(cur_win)
  local nvmenu_bufs = {}

  for i, id in ipairs(state.bufids) do
    if i > get_bufi(cur_buf) then
      table.insert(nvmenu_bufs, id)
    end
  end

  return nvmenu_bufs
end

M.switch_win = function(n)
  local cur_i = get_bufi(api.nvim_get_current_buf())

  if n == -1 and cur_i == 1 then
    cur_i = #state.bufids + 1
  elseif n == 1 and cur_i == #state.bufids then
    cur_i = 0
  end

  local buf = state.bufids[cur_i + n]
  api.nvim_set_current_win(fn.bufwinid(buf))
end

M.delete_old_menus = function()
  local old_bufs = require("menu.state").bufids

  if #old_bufs > 0 then
    vim.api.nvim_buf_call(old_bufs[1], function()
      vim.api.nvim_feedkeys("q", "x", false)
    end)
  end
end

M.toggle_nested_menu = function(name, items)
  local right_bufs = M.adjacent_bufs()

  if #right_bufs > 0 then
    require("volt.utils").close {
      bufs = right_bufs,
      close_func = function(buf)
        state.bufs[buf] = nil

        for i, val in ipairs(state.bufids) do
          if val == buf then
            table.remove(state.bufids, i)
          end
        end
      end,
    }

    if name ~= state.nested_menu then
      require("menu").open(items, { nested = true })
    end
  else
    require("menu").open(items, { nested = true })
  end

  state.nested_menu = name == state.nested_menu and "" or name
end

return M
