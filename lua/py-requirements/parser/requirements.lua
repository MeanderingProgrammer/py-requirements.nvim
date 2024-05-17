local ts = require('py-requirements.parser.ts')

---@param source (integer|string)
---@param root TSNode
---@return py.requirements.ParsedPythonModule?
local function parse_module(source, root)
    local requirements = ts:new('requirements', source, root)
    local name_node = requirements:query('(requirement (package) @package)')
    if name_node == nil then
        return nil
    end
    local comparison_node = requirements:query('(version_spec (version_cmp) @cmp)')
    local comparison = nil
    if comparison_node then
        comparison = comparison_node.value
    end
    ---@type py.requirements.ParsedPythonModule
    return {
        line_number = root:start(),
        name = name_node.value,
        comparison = comparison,
        version = requirements:query('(version_spec (version) @version)'),
    }
end

local M = {}

---@param buf integer
---@return py.requirements.ParsedPythonModule[]
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
---@return py.requirements.ParsedPythonModule?
function M.parse_module_string(line)
    --Adding a 0 at the end as if we started typing a version number
    line = line .. '0'
    local tree = vim.treesitter.get_string_parser(line, 'requirements')
    return parse_module(line, tree:parse()[1]:root())
end

return M
