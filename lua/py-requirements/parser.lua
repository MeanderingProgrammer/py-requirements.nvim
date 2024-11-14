local pypi = require('py-requirements.pypi')
local requirements = require('py-requirements.parser.requirements')

---@class py.reqs.Node
---@field value string
---@field start_col integer
---@field end_col integer

---@class py.reqs.ParsedDependency
---@field line_number integer 0-indexed
---@field name string
---@field comparison? string
---@field version? py.reqs.Node

---@class py.reqs.Dependency
---@field line_number integer 0-indexed
---@field name string
---@field comparison? string
---@field version? py.reqs.Node
---@field versions py.reqs.dependency.Versions

---@class py.reqs.Parser
local M = {}

---@param buf integer
---@return py.reqs.Dependency[]
function M.dependencies(buf)
    return vim.tbl_map(M.to_dependency, requirements.parse_dependencies(buf))
end

---@param line string
---@return py.reqs.Dependency?
function M.dependency_string(line)
    local dependency = requirements.parse_dependency_string(line)
    return dependency ~= nil and M.to_dependency(dependency) or nil
end

---@private
---@param dependency py.reqs.ParsedDependency
---@return py.reqs.Dependency
function M.to_dependency(dependency)
    ---@type py.reqs.Dependency
    return {
        line_number = dependency.line_number,
        name = dependency.name,
        comparison = dependency.comparison,
        version = dependency.version,
        versions = pypi.INITIAL,
    }
end

---@param buf integer
---@param dependencies py.reqs.Dependency[]
---@return integer
function M.max_len(buf, dependencies)
    local result = 0
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for _, dependency in ipairs(dependencies) do
        local len = #lines[dependency.line_number + 1]
        result = math.max(result, len)
    end
    return result
end

return M
