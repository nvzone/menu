local manager = require "neo-tree.sources.manager"
local cc = require "neo-tree.sources.common.commands"

-- Get neo-tree state.
local function get_state()
  local state = manager.get_state_for_window()
  assert(state)
  state.config = state.config or {}
  return state
end

-- Call arbitrary neo-tree action.
local function call(what)
  return vim.schedule_wrap(function()
    local state = get_state()
    local cb = require("neo-tree.sources." .. state.name .. ".commands")[what] or cc[what]
    cb(state)
  end)
end

-- Copy path to clipboard. How is fnamemodify argument.
local function copy_path(how)
  return function()
    local node = get_state().tree:get_node()
    if node.type == "message" then return end
    vim.fn.setreg('"', vim.fn.fnamemodify(node.path, how))
    vim.fn.setreg("+", vim.fn.fnamemodify(node.path, how))
  end
end

-- Open the path to currently selected item in the terminal.
local function open_in_terminal()
  return function()
    local node = get_state().tree:get_node()
    if node.type == "message" then return end
    local path = node.path
    local node_type = vim.uv.fs_stat(path).type
    local dir = node_type == "directory" and path or vim.fn.fnamemodify(path, ":h")
    vim.cmd "enew"
    vim.fn.termopen { vim.o.shell, "-c", "cd " .. dir .. " ; " .. vim.o.shell }
  end
end

return {
  -- NAVIGATION
  { name = "  Open in window", cmd = call "open", rtxt = "o" },
  { name = "  Open in vertical split", cmd = call "open_vsplit", rtxt = "v" },
  { name = "  Open in horizontal split", cmd = call "open_split", rtxt = "s" },
  { name = "󰓪  Open in new tab", cmd = call "open_tabnew", rtxt = "O" },
  { name = "separator" },
  -- FILE ACTIONS
  { name = "  New file", cmd = call "add", rtxt = "a" },
  { name = "  New folder", cmd = call "add_directory", rtxt = "A" },
  { name = "  Delete", hl = "ExRed", cmd = call "Delete", rtxt = "d" },
  { name = "   File details", cmd = call "show_file_details", rtxt = "i" },
  { name = "  Rename", cmd = call "rename", rtxt = "r" },
  { name = "  Rename basename", cmd = call "rename", rtxt = "b" },
  { name = "  Copy", cmd = call "copy_to_clipboard", rtxt = "y" },
  { name = "  Cut", cmd = call "cut_to_clipboard", rtxt = "x" },
  { name = "  Paste", cmd = call "paste_from_clipboard", rtxt = "p" },
  { name = "separator" },
  -- VIEW CHANGES
  { name = "Toggle hidden", cmd = call "toggle_hidden", rtxt = "R" },
  { name = "Refresh", cmd = call "refresh", rtxt = "R" },
  {
    name = "Sort by...",
    rtxt = "o",
    items = {
      { name = "Sort the tree by created date.", cmd = call "order_by_created", rtxt = "c" },
      { name = "Sort by diagnostic severity.", cmd = call "order_by_diagnostics", rtxt = "d" },
      { name = "Sort by git status.", cmd = call "order_by_git_status", rtxt = "g" },
      { name = "Sort by last modified date.", cmd = call "order_by_modified", rtxt = "m" },
      { name = "Sort by name (default sort).", cmd = call "order_by_name", rtxt = "n" },
      { name = "Sort by size.", cmd = call "order_by_size", rtxt = "s" },
      { name = "Sort by type.", cmd = call "order_by_type", rtxt = "t" },
    },
  },
  -- FILTER
  { name = "Fuzzy finder", cmd = call "fuzzy_finder", rtxt = "/" },
  { name = "Fuzzy finder directory", cmd = call "fuzzy_finder_directory", rtxt = "D" },
  { name = "Fuzzy sorter", cmd = call "fuzzy_sorter", rtxt = "#" },
  { name = "separator" },
  -- others
  { name = "󰴠  Copy absolute path", cmd = copy_path ":p", rtxt = "gy" },
  { name = "  Copy relative path", cmd = copy_path ":~:.", rtxt = "Y" },
  { name = "  Open in terminal", hl = "ExBlue", cmd = open_in_terminal() },
}
