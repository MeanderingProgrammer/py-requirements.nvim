local ts = require('py-requirements.parser.ts')

---@param source (integer|string)
---@param root TSNode
---@return ParsedPythonModule|nil
local function parse_module(source, root)
    local name_node = ts.query('toml', source, root, '(pair (bare_key) @package)')
    if name_node == nil or name_node.value == 'python' then
        return nil
    end
    ---@type ParsedPythonModule
    return {
        line_number = root:start(),
        name = name_node.value,
    }
end

local M = {}

---@param buf integer
---@return ParsedPythonModule[]
function M.parse_modules(buf)
    local modules = {}
    local tree = vim.treesitter.get_parser(buf, 'toml')
    local query = vim.treesitter.query.parse(
        'toml',
        [[
            (
                (table (dotted_key) @key (pair) @pair)
                (#eq? @key "tool.poetry.dependencies")
            )
        ]]
    )
    for id, node in query:iter_captures(tree:parse()[1]:root(), buf, 0, -1) do
        local name = query.captures[id]
        if name == 'pair' then
            local module = parse_module(buf, node)
            if module then
                table.insert(modules, module)
            end
        end
    end
    return modules
end

---@param line string
---@return ParsedPythonModule|nil
function M.parse_module_string(line)
    local tree = vim.treesitter.get_string_parser(line, 'toml')
    local module = parse_module(line, tree:parse()[1]:root())
    if module then
        module.comparison = '=='
        return module
    else
        return nil
    end
end

---@type PythonModuleParser
return {
    parse_modules = M.parse_modules,
    parse_module_string = M.parse_module_string,
}
