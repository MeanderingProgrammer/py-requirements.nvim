local state = require('py-requirements.state')

---@class py.reqs.parser.Requirements
local M = {}

---@param buf integer
---@return py.reqs.ParsedDependency[]
function M.parse_dependencies(buf)
    local dependencies = {}
    local tree = assert(vim.treesitter.get_parser(buf, 'requirements'))
    for _, node in state.requirement_query:iter_captures(tree:parse()[1]:root(), buf) do
        local dependency = M.parse_dependency(buf, node)
        if dependency then
            dependencies[#dependencies + 1] = dependency
        end
    end
    return dependencies
end

---@param line string
---@return py.reqs.ParsedDependency?
function M.parse_dependency_string(line)
    --Adding a 0 at the end as if we started typing a version number
    line = line .. '0'
    local tree = vim.treesitter.get_string_parser(line, 'requirements')
    return M.parse_dependency(line, tree:parse()[1]:root())
end

---@private
---@param source (integer|string)
---@param root TSNode
---@return py.reqs.ParsedDependency?
function M.parse_dependency(source, root)
    local name, comparison, version = nil, nil, nil
    for id, node in state.dependency_query:iter_captures(root, source) do
        local capture = state.dependency_query.captures[id]
        local value = vim.treesitter.get_node_text(node, source)
        if capture == 'name' then
            name = value
        elseif capture == 'cmp' then
            comparison = value
        elseif capture == 'version' then
            local _, start_col, _, end_col = node:range()
            ---@type py.reqs.Node
            version = {
                value = value,
                start_col = start_col,
                end_col = end_col,
            }
        end
    end

    if name == nil then
        return nil
    end
    ---@type py.reqs.ParsedDependency
    return {
        line_number = root:start(),
        name = name,
        comparison = comparison,
        version = version,
    }
end

return M
