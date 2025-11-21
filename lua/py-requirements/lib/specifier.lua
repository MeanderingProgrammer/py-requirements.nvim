---@class py.reqs.Specifier
local M = {}

---@param version1 string
---@param cmp string
---@param version2 string
---@return boolean
function M.matches(version1, cmp, version2)
    if not vim.version then
        return version1 == version2
    end
    local v1 = vim.version.parse(version1)
    local v2 = vim.version.parse(version2)
    if not v1 or not v2 then
        return false
    elseif cmp == '==' or cmp == '===' then
        return v1 == v2
    elseif cmp == '<' then
        return v1 < v2
    elseif cmp == '<=' then
        return v1 <= v2
    elseif cmp == '>' then
        return v1 > v2
    elseif cmp == '>=' then
        return v1 >= v2
    elseif cmp == '~=' then
        return v1 >= v2 and vim.version.lt(v1, { v2.major + 1, 0, 0 })
    else
        error(('invalid comparison: %s'):format(cmp))
    end
end

return M
