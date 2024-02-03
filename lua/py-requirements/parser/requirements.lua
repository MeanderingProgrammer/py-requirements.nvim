local ts = require('py-requirements.parser.ts')

---@param source (integer|string)
---@param root TSNode
---@return ParsedPythonModule|nil
local function parse_module(source, root)
    local name_node = ts.query('requirements', source, root, '(requirement (package) @package)')
    if name_node == nil then
        return nil
    end
    local comparison_node = ts.query('requirements', source, root, '(version_spec (version_cmp) @cmp)')
    local comparison = nil
    if comparison_node then
        comparison = comparison_node.value
    end
    ---@type ParsedPythonModule
    return {
        line_number = root:start(),
        name = name_node.value,
        comparison = comparison,
        version = ts.query('requirements', source, root, '(version_spec (version) @version)'),
    }
end

local M = {}

---@param buf integer
---@return ParsedPythonModule[]
function M.parse_modules(buf)
    local modules = {}
    local tree = vim.treesitter.get_parser(buf, 'requirements')
    local query = vim.treesitter.query.parse('requirements', '((requirement) @requirement)')
    for _, node in query:iter_captures(tree:parse()[1]:root(), buf, 0, -1) do
        local module = parse_module(buf, node)
        if module then
            table.insert(modules, module)
        end
    end
    return modules
end

---@param line string
---@return ParsedPythonModule|nil
function M.parse_module_string(line)
    --Adding a 0 at the end as if we started typing a version number
    line = line .. '0'
    local tree = vim.treesitter.get_string_parser(line, 'requirements')
    return parse_module(line, tree:parse()[1]:root())
end

return M
