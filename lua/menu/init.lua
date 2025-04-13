local M = {}
local state = require "menu.state"
local layout = require "menu.layout"
local ns = vim.api.nvim_create_namespace "NvMenu"
local volt = require "volt"
local volt_events = require "volt.events"
local mappings = require "menu.mappings"
local utils = require "menu.utils"

---@class MenuItem
---@field name string
---@field cmd? string|fun():any
---@field items? MenuItem[]|fun():MenuItem[]
---@field rtxt? string
---@field hl? string

---@class MenuOpenOpts
---@field mouse? boolean
---@field nested? boolean

---@param items string|MenuItem[]|fun():MenuItem[]
---@param opts MenuOpenOpts
M.open = function(items, opts)
  opts = opts or {}

  local cur_buf = vim.api.nvim_get_current_buf()

  if vim.bo[cur_buf].ft ~= "NvMenu" then
    state.old_data = {
      buf = vim.api.nvim_get_current_buf(),
      win = vim.api.nvim_get_current_win(),
      cursor = vim.api.nvim_win_get_cursor(0),
    }
  end

  local items_was = type(items)
  if type(items) == "function" then
    items = items()
  end
  if type(items) == "string" then
    items = require("menus." .. items)
    if type(items) == "function" then
      items = items()
    end
  end
  assert(
    type(items) == "table",
    "Items has to be a table."
      .. " items_was="
      .. items_was
      .. " type(items)="
      .. type(items)
      .. " vim.inspect(items)="
      .. vim.inspect(items)
      .. " vim.inspect(opts)="
      .. vim.inspect(opts)
      .. ". Most probably provided menus configuration is invalid."
  )

  if not state.config then
    state.config = opts
  end

  local config = state.config

  local buf = vim.api.nvim_create_buf(false, true)
  state.bufs[buf] = { items = items, item_gap = M.config.item_gap or 5 }
  table.insert(state.bufids, buf)

  local h = #items
  local bufv = state.bufs[buf]
  bufv.w = utils.get_width(items)
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
      win_opts.col = vim.api.nvim_win_get_width(pos.winid) + 2
      win_opts.row = pos.winrow - 2
    else
      win_opts.win = vim.api.nvim_get_current_win()
      win_opts.col = vim.api.nvim_win_get_width(win_opts.win) + 2
      win_opts.row = vim.api.nvim_win_get_cursor(win_opts.win)[1] - 1
    end
  end

  local win = vim.api.nvim_open_win(buf, not config.mouse, win_opts)

  volt.gen_data {
    { buf = buf, ns = ns, layout = layout },
  }

  if M.config.border then
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

    if vim.api.nvim_win_is_valid(state.old_data.win) then
      vim.api.nvim_set_current_win(state.old_data.win)
      vim.schedule(function()
        local cursor_line = math.max(1, state.old_data.cursor[1])
        local cursor_col = math.max(0, state.old_data.cursor[2])

        vim.api.nvim_win_set_cursor(state.old_data.win, { cursor_line, cursor_col })
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

M.delete_old_menus = utils.delete_old_menus

---@class MenuConfig
---@field ft? {string: string|MenuItem|fun():MenuItem}
---@field default_menu? string|MenuItem
---@field default_mappings? boolean
---@field border? boolean
---@field item_gap? integer

---@type MenuConfig
M.config = {
  ft = {},
  default_menu = "default",
  default_mappings = false,
  border = false,
  item_gap = 5,
}

---@param args MenuConfig
M.setup = function(args)
  M.config = vim.tbl_deep_extend("force", M.config, args or {})
  if M.config.default_mappings then
    vim.keymap.set("n", "<C-t>", function()
      M.handler { mouse = false }
    end)
    vim.keymap.set({ "n", "v" }, "<RightMouse>", function()
      M.handler { mouse = true }
    end)
  end
end

---@param opts MenuOpenOpts
M.handler = function(opts)
  opts = opts or {}
  local window = 0
  if opts.mouse then
    -- On second mouse click remove current manu and reopen it.
    require("menu.utils").delete_old_menus()
    vim.cmd.exec '"normal! \\<RightMouse>"'
    window = vim.api.nvim_win_get_buf(vim.fn.getmousepos().winid)
  else
    if #require("menu.state").bufids > 0 then
      -- if a menu is already open, close it.
      require("menu.utils").delete_old_menus()
      return
    end
  end
  local ft = vim.bo[vim.api.nvim_win_get_buf(window)].ft
  -- First try user filetype overwrites.
  local items = M.config.ft[ft]
  if not items then
    -- Then try filetype specific menus.
    local ok, mod = pcall(require, "menus.ft." .. ft)
    if ok then
      items = mod
    else
      -- Fallback to defaults.
      items = M.config.default_menu or "default"
    end
  end
  M.open(items, opts)
end

return M
