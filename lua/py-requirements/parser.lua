local requirements = require('py-requirements.parser.requirements')

---@class py.reqs.Parser
local M = {}

---@param buf integer
---@return py.reqs.Package[]
function M.packages(buf)
    return requirements.packages(buf)
end

---@param line string
---@return py.reqs.Package?
function M.line(line)
    return requirements.line(line)
end

---@param buf integer
---@param packages py.reqs.Package[]
---@return integer
function M.max_len(buf, packages)
    local result = 0
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for _, package in ipairs(packages) do
        result = math.max(result, #lines[package.row + 1])
    end
    return result
end

return M
