---@param line string
---@return string
local function uncomment(line)
    -- Capture everything before a #
    -- If nothing mathces (no # exists) return the input
    return line:match('^([^#]*)#.*$') or line
end

---@param line string
---@return string
local function remove_whitespace(line)
    local result, _ = line:gsub('%s+', '')
    return result
end

---@param line string
---@param operator string
---@return string|nil
---@return string|nil
local function dependency(line, operator)
    local name, version = line:match('^(.*)' .. operator .. '(.*)$')
    return name, version
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
---@field version string
---@field versions string[]

local M = {}

---@param line_number integer
---@param line string
---@return PythonModule|nil
function M.parse_module(line_number, line)
    -- Reference
    -- https://pip.pypa.io/en/stable/reference/requirements-file-format/
    -- https://pip.pypa.io/en/stable/reference/requirement-specifiers/

    line = uncomment(line)
    line = remove_whitespace(line)
    if line:len() == 0 then
        return nil
    end

    local dependency_operator = {
        ['=='] = DependencyKind.EQUAL,
        ['<'] = DependencyKind.LESS,
        ['<='] = DependencyKind.LESS_OR_EQUAL,
        ['>='] = DependencyKind.GREATER_OR_EQUAL,
        ['>'] = DependencyKind.GREATER,
        ['~='] = DependencyKind.COMPATIBLE,
    }

    for operator, kind in pairs(dependency_operator) do
        local name, version = dependency(line, operator)
        if name and version then
            ---@type PythonModule
            return {
                line_number = line_number,
                name = name,
                kind = kind,
                version = version,
                versions = {},
            }
        end
    end

    return nil
end

---@param buf integer
---@return PythonModule[]
function M.parse_modules(buf)
    local modules = {}
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i, line in ipairs(lines) do
        local module = M.parse_module(i - 1, line)
        if module then
            table.insert(modules, module)
        end
    end
    return modules
end

return M
