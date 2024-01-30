local api = require('py-requirements.api')

---@class Node
---@field value string
---@field start_col integer
---@field end_col integer

---@param source (integer|string)
---@param root TSNode
---@param query string
---@return Node|nil
local function run_query(source, root, query)
    local parsed_query = vim.treesitter.query.parse('requirements', query)
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

---@class PythonModule
---@field line_number integer 0-indexed
---@field name string
---@field comparison? string
---@field version? Node
---@field versions ModuleVersions
---@field description? ModuleDescription

local M = {}

---@param buf integer
---@param modules PythonModule[]
---@return integer
function M.max_len(buf, modules)
    local result = 0
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for _, module in ipairs(modules) do
        local len = #lines[module.line_number + 1]
        result = math.max(result, len)
    end
    return result
end

---@param line string
---@return PythonModule|nil
function M.parse_module_string(line)
    local tree = vim.treesitter.get_string_parser(line, 'requirements')
    return M.parse_module(line, tree:parse()[1]:root())
end

---@param source (integer|string)
---@param root TSNode
---@return PythonModule|nil
function M.parse_module(source, root)
    local name_node = run_query(source, root, '(requirement (package) @package)')
    if name_node == nil then
        return nil
    end
    local comparison_node = run_query(source, root, '(version_spec (version_cmp) @cmp)')
    local comparison = nil
    if comparison_node then
        comparison = comparison_node.value
    end
    ---@type PythonModule
    return {
        line_number = root:start(),
        name = name_node.value,
        comparison = comparison,
        version = run_query(source, root, '(version_spec (version) @version)'),
        versions = api.INITIAL,
    }
end

---@param buf integer
---@return PythonModule[]
function M.parse_modules(buf)
    local modules = {}
    local tree = vim.treesitter.get_parser(buf, 'requirements')
    local query = vim.treesitter.query.parse('requirements', '((requirement) @requirement)')
    for _, node in query:iter_captures(tree:parse()[1]:root(), buf, 0, -1) do
        local module = M.parse_module(buf, node)
        if module then
            table.insert(modules, module)
        end
    end
    return modules
end

return M
