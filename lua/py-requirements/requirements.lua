---@param line string
---@param query string
---@return string|nil, integer|nil, integer|nil
local function run_query(root, line, query)
    local parsed_query = vim.treesitter.query.parse('requirements', query)
    for _, node in parsed_query:iter_captures(root, line, 0, -1) do
        local _, start_col, _, end_col = node:range()
        return vim.treesitter.get_node_text(node, line), start_col, end_col
    end
    return nil, nil, nil
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
---@field kind DependencyKind
---@field version VersionSpecification
---@field versions string[]

---@class VersionSpecification
---@field version string|nil
---@field start_col integer|nil
---@field end_col integer|nil

local M = {}

---@param line_number integer
---@param line string
---@return PythonModule|nil
function M.parse_module(line_number, line)
    if string.match(line, '^%s*--hash') then
        return nil
    end

    --Adding a blank line at the end generally helps parser pull more information
    line = line .. '\n'
    local root = vim.treesitter.get_string_parser(line, 'requirements'):parse()[1]:root()
    local name = run_query(root, line, '(requirement (package) @package)')
    local cmp = run_query(root, line, '(requirement (version_spec (version_cmp) @cmp))')
    local version, start_col, end_col = run_query(root, line, '(requirement (version_spec (version) @version))')
    if name == nil then
        return nil
    end
    local cmp_mapping = {
        ['=='] = DependencyKind.EQUAL,
        ['<'] = DependencyKind.LESS,
        ['<='] = DependencyKind.LESS_OR_EQUAL,
        ['>='] = DependencyKind.GREATER_OR_EQUAL,
        ['>'] = DependencyKind.GREATER,
        ['~='] = DependencyKind.COMPATIBLE,
    }
    ---@type PythonModule
    return {
        line_number = line_number,
        name = name,
        kind = cmp_mapping[cmp],
        version = {
            version = version,
            start_col = start_col,
            end_col = end_col,
        },
        versions = {},
    }
end

---@param buf integer
---@param start_line? integer
---@param end_line? integer
---@return PythonModule[]
function M.parse_modules(buf, start_line, end_line)
    local modules = {}
    start_line = start_line or 0
    end_line = end_line or -1
    local lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)
    for i, line in ipairs(lines) do
        local module = M.parse_module(start_line + i - 1, line)
        if module then
            table.insert(modules, module)
        end
    end
    return modules
end

return M
