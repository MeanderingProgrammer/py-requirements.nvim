local state = require('py-requirements.state')

---@class py.requirements.parser.Requirements
local M = {}

---@param buf integer
---@return py.requirements.ParsedPythonModule[]
function M.parse_modules(buf)
    local modules = {}
    local tree = vim.treesitter.get_parser(buf, 'requirements')
    for _, node in state.requirement_query:iter_captures(tree:parse()[1]:root(), buf) do
        local module = M.parse_module(buf, node)
        if module then
            table.insert(modules, module)
        end
    end
    return modules
end

---@param line string
---@return py.requirements.ParsedPythonModule?
function M.parse_module_string(line)
    --Adding a 0 at the end as if we started typing a version number
    line = line .. '0'
    local tree = vim.treesitter.get_string_parser(line, 'requirements')
    return M.parse_module(line, tree:parse()[1]:root())
end

---@private
---@param source (integer|string)
---@param root TSNode
---@return py.requirements.ParsedPythonModule?
function M.parse_module(source, root)
    local name, comparison, version = nil, nil, nil
    for id, node in state.module_query:iter_captures(root, source) do
        local capture = state.module_query.captures[id]
        local value = vim.treesitter.get_node_text(node, source)
        if capture == 'name' then
            name = value
        elseif capture == 'cmp' then
            comparison = value
        elseif capture == 'version' then
            local _, start_col, _, end_col = node:range()
            ---@type py.requirements.Node
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
    ---@type py.requirements.ParsedPythonModule
    return {
        line_number = root:start(),
        name = name,
        comparison = comparison,
        version = version,
    }
end

return M
