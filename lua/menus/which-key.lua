---@param self string
---@param start string
local function string_startswith(self, start)
  ---@diagnostic disable-next-line: param-type-mismatch
  return self:sub(1, #start) == start
end

local walk

---@param node wk.Node
---@param prefix string?
---@return MenuItem[]?
local node_to_item = function(node, prefix)
  -- Create the name.
  local name = node.mapping and node.mapping.desc or node.keymap and (node.keymap.desc or node.keymap.rhs) or node.keys
  -- Create element to add. Elements with children have items.
  if next(node._children) then
    -- If item has children, descend to them.
    return {
      name = name .. " " .. node.path[#node.path],
      items = function()
        return walk(node, prefix) or {}
      end,
      hl = "Exblue",
      rtxt = node.path[#node.path],
    }
  else
    -- If item has no children, execute a normal command as part of it.
    local feed = vim.api.nvim_replace_termcodes(node.keys, true, true, true)
    local cmd = node.action
      or node.keymap and node.keymap.callback
      or function()
        vim.api.nvim_feedkeys(feed, "mit", false)
      end
    return { name = name, cmd = cmd, rtxt = node.path[#node.path] }
  end
end

---@param node wk.Node
---@param prefix string?
---@return MenuItem[]?
walk = function(node, prefix)
  ---@type MenuItem[]
  local items = nil
  local children = node._children
  if children then
    items = {}
    for _, child in pairs(children) do
      if child and child.keys and (not prefix or prefix == "" or string_startswith(child.keys, prefix)) then
        table.insert(items, node_to_item(child, prefix))
      end
    end
    table.sort(items, function(a, b)
      return a.name < b.name
    end)
  end
  return items
end

---@param prefix string?
---@param mode string?
return function(prefix, mode)
  local root = require("which-key.buf").get({ mode = mode or "n" }).tree.root
  -- print(vim.inspect(root))
  prefix = prefix and vim.g.mapleader:gsub(prefix, "<Space>")
  local items = walk(root, prefix)
  -- print(vim.inspect(menu))
  return items and next(items) and items or nil
end
