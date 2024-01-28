---@param source (integer|string)
---@param root TSNode
---@param query string
---@return string|nil
local function run_query(source, root, query)
    local parsed_query = vim.treesitter.query.parse('requirements', query)
    for _, node in parsed_query:iter_captures(root, source, 0, -1) do
        return vim.treesitter.get_node_text(node, source)
    end
    return nil
end

---@enum DependencyKind
local DependencyKind = {
    EQUAL = 1,
    LESS = 2,
    LESS_OR_EQUAL = 3,
    GREATER_OR_EQUAL = 4,
    GREATER = 5,
    COMPATIBLE = 6,
}

---@class PythonModule
---@field line_number integer 0-indexed
---@field name string
---@field kind? DependencyKind
---@field version? string
---@field versions string[]

local M = {}

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
    local name = run_query(source, root, '(requirement (package) @package)')
    if name == nil then
        return nil
    end
    local cmp_query = '(requirement (version_spec (version_cmp) @cmp))'
    local cmp_mapping = {
        ['=='] = DependencyKind.EQUAL,
        ['<'] = DependencyKind.LESS,
        ['<='] = DependencyKind.LESS_OR_EQUAL,
        ['>='] = DependencyKind.GREATER_OR_EQUAL,
        ['>'] = DependencyKind.GREATER,
        ['~='] = DependencyKind.COMPATIBLE,
    }
    local version_query = '(requirement (version_spec (version) @version))'
    ---@type PythonModule
    return {
        line_number = root:start(),
        name = name,
        kind = cmp_mapping[run_query(source, root, cmp_query)],
        version = run_query(source, root, version_query),
        versions = {},
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
