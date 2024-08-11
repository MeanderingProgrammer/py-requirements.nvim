---@class py.requirements.Node
---@field value string
---@field start_col integer
---@field end_col integer

---@class py.requirements.parser.Requirements
local M = {}

---@param buf integer
---@return py.requirements.ParsedPythonModule[]
function M.parse_modules(buf)
    local modules = {}
    local tree = vim.treesitter.get_parser(buf, 'requirements')
    local query = vim.treesitter.query.parse('requirements', '((requirement) @requirement)')
    for _, node in query:iter_captures(tree:parse()[1]:root(), buf) do
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
    ---@type table<string,py.requirements.Node>
    local captures = {}
    local query = vim.treesitter.query.parse(
        'requirements',
        [[
            (requirement (package) @name)
            (version_spec (version_cmp) @cmp)
            (version_spec (version) @version)
        ]]
    )
    for id, node in query:iter_captures(root, source) do
        local capture = query.captures[id]
        local _, start_col, _, end_col = node:range()
        ---@type py.requirements.Node
        local py_node = {
            value = vim.treesitter.get_node_text(node, source),
            start_col = start_col,
            end_col = end_col,
        }
        captures[capture] = py_node
    end

    if captures.name == nil then
        return nil
    end
    ---@type py.requirements.ParsedPythonModule
    return {
        line_number = root:start(),
        name = captures.name.value,
        comparison = vim.tbl_get(captures, 'cmp', 'value'),
        version = captures.version,
    }
end

return M
