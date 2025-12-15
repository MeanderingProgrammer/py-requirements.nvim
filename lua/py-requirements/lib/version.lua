local util = require('py-requirements.lib.util')

---@class py.reqs.Version
---@field private value string
---@field private parts (number|string)[]
local Version = {}
Version.__index = Version

---@param value string
---@return py.reqs.Version
function Version.new(value)
    local self = setmetatable({}, Version)
    self.value = value
    -- https://packaging.python.org/en/latest/specifications/version-specifiers
    self.parts = {}
    for _, part in ipairs(util.split(value, '.')) do
        self.parts[#self.parts + 1] = (tonumber(part) or part)
    end
    return self
end

---@param other py.reqs.Version
---@return boolean
function Version:__eq(other)
    return self.value == other.value
end

---@param other py.reqs.Version
---@return boolean
function Version:__lt(other)
    for i = 1, math.max(#self.parts, #other.parts) do
        local v1 = self.parts[i] or 0
        local v2 = other.parts[i] or 0
        if v1 ~= v2 then
            return v1 < v2
        end
    end
    return false
end

---@param other py.reqs.Version
---@return boolean
function Version:__le(other)
    return self < other or self == other
end

---@return boolean
function Version:final()
    for _, part in ipairs(self.parts) do
        if type(part) == 'string' then
            return false
        end
    end
    return true
end

---@return py.reqs.Version
function Version:next()
    local parts = { tostring(self.parts[1] + 1) } ---@type string[]
    for _ = 2, #self.parts do
        parts[#parts + 1] = tostring(0)
    end
    return Version.new(table.concat(parts, '.'))
end

return Version
