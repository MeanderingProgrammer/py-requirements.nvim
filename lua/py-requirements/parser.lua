local api = require('py-requirements.api')
local requirements = require('py-requirements.parser.requirements')

---@class py.requirements.ParsedPythonModule
---@field line_number integer 0-indexed
---@field name string
---@field comparison? string
---@field version? py.requirements.Node

---@class py.requirements.PythonModule
---@field line_number integer 0-indexed
---@field name string
---@field comparison? string
---@field version? py.requirements.Node
---@field versions py.requirements.ModuleVersions

---@param module py.requirements.ParsedPythonModule
---@return py.requirements.PythonModule
local function to_module(module)
    ---@type py.requirements.PythonModule
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
---@return py.requirements.PythonModule[]
function M.parse_modules(buf)
    return vim.tbl_map(to_module, requirements.parse_modules(buf))
end

---@param line string
---@return py.requirements.PythonModule?
function M.parse_module_string(line)
    local module = requirements.parse_module_string(line)
    if module then
        return to_module(module)
    else
        return nil
    end
end

---@param buf integer
---@param modules py.requirements.PythonModule[]
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
