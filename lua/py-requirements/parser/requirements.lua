local state = require('py-requirements.state')

---@class py.reqs.parser.Requirements
local M = {}

---@private
M.lang = 'requirements'

---@param buf integer
---@return py.reqs.ParsedDependency[]
function M.parse_dependencies(buf)
    local ok, tree = pcall(vim.treesitter.get_parser, buf, M.lang)
    if not ok or not tree then
        return {}
    end
    local query = M.parse(state.config.requirement_query)
    if not query then
        return {}
    end
    local dependencies = {} ---@type py.reqs.ParsedDependency[]
    local root = tree:parse()[1]:root()
    for _, node in query:iter_captures(root, buf) do
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
    local ok, tree = pcall(vim.treesitter.get_string_parser, line, M.lang)
    if not ok or not tree then
        return nil
    end
    return M.parse_dependency(line, tree:parse()[1]:root())
end

---@private
---@param source (integer|string)
---@param root TSNode
---@return py.reqs.ParsedDependency?
function M.parse_dependency(source, root)
    local query = M.parse(state.config.dependency_query)
    if not query then
        return nil
    end
    local name, comparison, version = nil, nil, nil
    for id, node in query:iter_captures(root, source) do
        local capture = query.captures[id]
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

---@private
---@param query string
---@return vim.treesitter.Query?
function M.parse(query)
    local ok, result = pcall(vim.treesitter.query.parse, M.lang, query)
    return ok and result or nil
end

return M
