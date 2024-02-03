local api = require('py-requirements.api')
local requirements = require('py-requirements.parser.requirements')

---@class ParsedPythonModule
---@field line_number integer 0-indexed
---@field name string
---@field comparison? string
---@field version? Node

---@class PythonModule
---@field line_number integer 0-indexed
---@field name string
---@field comparison? string
---@field version? Node
---@field versions ModuleVersions

---@param module ParsedPythonModule
---@return PythonModule
local function to_module(module)
    ---@type PythonModule
    return {
        line_number = module.line_number,
        name = module.name,
        comparison = module.comparison,
        version = module.version,
        versions = api.INITIAL,
    }
end

local M = {}

---@param buf integer
---@return PythonModule[]
function M.parse_modules(buf)
    local modules = {}
    for _, module in ipairs(requirements.parse_modules(buf)) do
        table.insert(modules, to_module(module))
    end
    return modules
end

---@param line string
---@return PythonModule|nil
function M.parse_module_string(line)
    local module = requirements.parse_module_string(line)
    if module then
        return to_module(module)
    else
        return nil
    end
end

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

return M
