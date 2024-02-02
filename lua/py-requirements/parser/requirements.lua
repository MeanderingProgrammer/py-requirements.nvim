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

---@param source (integer|string)
---@param root TSNode
---@return ParsedPythonModule|nil
local function parse_module(source, root)
    local name_node = run_query(source, root, '(requirement (package) @package)')
    if name_node == nil then
        return nil
    end
    local comparison_node = run_query(source, root, '(version_spec (version_cmp) @cmp)')
    local comparison = nil
    if comparison_node then
        comparison = comparison_node.value
    end
    ---@type ParsedPythonModule
    return {
        line_number = root:start(),
        name = name_node.value,
        comparison = comparison,
        version = run_query(source, root, '(version_spec (version) @version)'),
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
    local tree = vim.treesitter.get_string_parser(line, 'requirements')
    return parse_module(line, tree:parse()[1]:root())
end

---@type PythonModuleParser
return {
    parse_modules = M.parse_modules,
    parse_module_string = M.parse_module_string,
}
