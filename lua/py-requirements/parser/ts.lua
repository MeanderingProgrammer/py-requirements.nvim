---@class Node
---@field value string
---@field start_col integer
---@field end_col integer

---@class TS
---@field lang string
---@field source (integer|string)
---@field root TSNode
local TS = {}
TS.__index = TS

---@param lang string
---@param source (integer|string)
---@param root TSNode
---@return TS
function TS:new(lang, source, root)
    ---@type TS
    local obj = { lang = lang, source = source, root = root }
    setmetatable(obj, self)
    return obj
end

---@param query string
---@return Node|nil
function TS:query(query)
    local parsed_query = vim.treesitter.query.parse(self.lang, query)
    for _, node in parsed_query:iter_captures(self.root, self.source, 0, -1) do
        local _, start_col, _, end_col = node:range()
        ---@type Node
        return {
            value = vim.treesitter.get_node_text(node, self.source),
            start_col = start_col,
            end_col = end_col,
        }
    end
    return nil
end

return TS
