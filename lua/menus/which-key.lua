function string_startswith(self, start)
  ---@diagnostic disable-next-line: param-type-mismatch
  return self:sub(1, #start) == start
end

local walk

local node_to_item = function(node, prefix)
  -- Create the name.
  local name = node.keymap and (node.keymap.desc or node.keymap.rhs) or node.keys
  -- Create key string that will be triggered in normal mode by this shortcut.
  local keys = node.keys:gsub("<Space>", " "):gsub("^ ", "1 ")
  -- Create element to add. Elements with children have items.
  if next(node._children) == nil then
    -- If item has no children, execute a normal command as part of it.
    return { name = name, cmd = function() vim.cmd("normal! " .. keys) end, rtxt = keys:sub(-1) }
  else
    -- If item has children, descend to them.
    return { name = name, items = function() walk(node, prefix) end, rtxt = keys:sub(-1) }
  end
end

---@param node wk.Node
---@param prefix string
walk = function(node, prefix)
  local items = {}
  local children = node._children
  assert(children ~= nil, vim.inspect(node))
  for _, child in pairs(children) do
    if string_startswith(child.keys, prefix) then table.insert(items, node_to_item(child, prefix)) end
  end
  return items
end

local menu = walk(require("which-key.buf").get({ mode = "n" }).tree.root, "<Space>")
print(vim.inspect(menu))
return menu

-- ---@param node wk.Node
-- ---@param prefix string
-- local function walker(node, prefix)
--   -- Only filter on the prefix.
--   if not string_startswith(node.keys, prefix) then return end
--   -- Extract parents
--   local parents = {}
--   if true then
--     local parent = node.parent
--     while parent do
--       table.insert(parents, 1, parent)
--       parent = parent.parent
--     end
--   end
--   -- Find the current node to add to.
--   local cur = root
--   if true then
--     local prev = nil
--     for i, key in ipairs(node.path) do
--       -- Ignore last - we will add element for it
--       if i == #node.path then break end
--       -- Iterate over elements in cur to find if it matches.
--       local found = nil
--       for _, j in ipairs(cur) do
--         if j.rtxt == key then
--           found = cur
--           break
--         end
--       end
--       assert(found, vim.inspect(node) .. vim.inspect(cur))
--       cur = found.items
--     end
--   end
--   --
--   table.insert(cur, add)
--   --
--   return add
-- end
--
-- require("which-key.buf").get({ mode = "n" }).tree:walk(function(node) return walker(node, "<Space>") end)
--
-- print(vim.inspect(root))
--
