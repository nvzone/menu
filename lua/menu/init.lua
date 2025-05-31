local M = {}
local api = vim.api
local state = require "menu.state"
local layout = require "menu.layout"
local ns = api.nvim_create_namespace "NvMenu"
local volt = require "volt"
local volt_events = require "volt.events"
local mappings = require "menu.mappings"

M.open = function(items, opts)
  opts = opts or {}

  local cur_buf = api.nvim_get_current_buf()

  if vim.bo[cur_buf].ft ~= "NvMenu" then
    state.old_data = {
      buf = api.nvim_get_current_buf(),
      win = api.nvim_get_current_win(),
      cursor = api.nvim_win_get_cursor(0),
    }
  end

  items = type(items) == "table" and items or require("menus." .. items)

  if not state.config then
    state.config = opts
  end

  local config = state.config

  local buf = api.nvim_create_buf(false, true)
  state.bufs[buf] = { items = items, item_gap = opts.item_gap or 5 }
  table.insert(state.bufids, buf)

  local h = #items
  local bufv = state.bufs[buf]
  bufv.w = require("menu.utils").get_width(items)
  bufv.w = bufv.w + bufv.item_gap

  local win_opts = {
    relative = config.mouse and "mouse" or "cursor",
    width = bufv.w,
    height = h,
    row = 1,
    col = 0,
    border = "single",
    style = "minimal",
    zindex = 99 + #state.bufids,
  }

  if opts.nested then
    win_opts.relative = "win"

    if config.mouse then
      local pos = vim.fn.getmousepos()
      win_opts.win = pos.winid
      win_opts.col = api.nvim_win_get_width(pos.winid) + 2
      win_opts.row = pos.winrow - 2
    else
      win_opts.win = api.nvim_get_current_win()
      win_opts.col = api.nvim_win_get_width(win_opts.win) + 2
      win_opts.row = api.nvim_win_get_cursor(win_opts.win)[1] - 1
    end
  end

  local win = api.nvim_open_win(buf, not config.mouse, win_opts)

  volt.gen_data {
    { buf = buf, ns = ns, layout = layout },
  }

  if config.border then
    vim.wo[win].winhl = "Normal:Normal,FloatBorder:LineNr"
  else
    vim.wo[win].winhl = "Normal:ExBlack2Bg,FloatBorder:ExBlack2Border"
  end

  volt.run(buf, { h = h, w = bufv.w })
  vim.bo[buf].filetype = "NvMenu"

  volt_events.add(buf)

  local close_post = function()
    state.bufs = {}
    state.config = nil
    state.nested_menu = ""

    if api.nvim_win_is_valid(state.old_data.win) then
      api.nvim_set_current_win(state.old_data.win)
      vim.schedule(function()
        local cursor_line = math.max(1, state.old_data.cursor[1])
        local cursor_col = math.max(0, state.old_data.cursor[2])

        pcall(api.nvim_win_set_cursor, state.old_data.win, { cursor_line, cursor_col })
      end)
    end

    state.bufids = {}
  end

  volt.mappings { bufs = vim.tbl_keys(state.bufs), after_close = close_post }

  if not config.mouse then
    mappings.nav_win()
    mappings.actions(items, buf)
  else
    mappings.auto_close()
  end
end

return M
