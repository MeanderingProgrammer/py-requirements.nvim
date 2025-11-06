---@class py.reqs.parser.Language
---@field packages fun(buf: integer): py.reqs.Package[]
---@field line fun(str: string): py.reqs.Package?

---@type table<string, py.reqs.parser.Language>
local parsers = {
    requirements = require('py-requirements.parser.requirements'),
}

---@class py.reqs.Parser
local M = {}

---@param buf integer
---@return py.reqs.Package[]
function M.packages(buf)
    return M.get(buf).packages(buf)
end

---@param buf integer
---@param str string
---@return py.reqs.Package?
function M.line(buf, str)
    -- adding a 0 to the end as if we started typing a version number
    return M.get(buf).line(str .. '0')
end

---@private
---@param buf integer
---@return py.reqs.parser.Language
function M.get(buf)
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })
    return parsers[filetype] or parsers.requirements
end

return M
