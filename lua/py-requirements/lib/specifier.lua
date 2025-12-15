local Version = require('py-requirements.lib.version')

---@class py.reqs.Specifier
local M = {}

---@param version1 string
---@param cmp string
---@param version2 string
---@return boolean
function M.matches(version1, cmp, version2)
    local v1 = Version.new(version1)
    local v2 = Version.new(version2)
    if cmp == '===' or cmp == '==' then
        return v1 == v2
    elseif cmp == '!=' then
        return v1 ~= v2
    elseif cmp == '<' then
        return v1 < v2
    elseif cmp == '<=' then
        return v1 <= v2
    elseif cmp == '>' then
        return v1 > v2
    elseif cmp == '>=' then
        return v1 >= v2
    elseif cmp == '~=' then
        return v1 >= v2 and v1 < v2:next()
    else
        error(('invalid comparison: %s'):format(cmp))
    end
end

return M
