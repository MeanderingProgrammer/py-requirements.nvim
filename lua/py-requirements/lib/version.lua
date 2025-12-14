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

---@return boolean
function Version:final()
    for _, part in ipairs(self.parts) do
        if type(part) == 'string' then
            return false
        end
    end
    return true
end

return Version
