---@class Node
---@field value string
---@field start_col integer
---@field end_col integer

local M = {}

---@param lang string
---@param source (integer|string)
---@param root TSNode
---@param query string
---@return Node|nil
function M.query(lang, source, root, query)
    local parsed_query = vim.treesitter.query.parse(lang, query)
    for _, node in parsed_query:iter_captures(root, source, 0, -1) do
        local _, start_col, _, end_col = node:range()
        ---@type Node
        return {
            value = vim.treesitter.get_node_text(node, source),
            start_col = start_col,
            end_col = end_col,
        }
    end
    return nil
end

return M
