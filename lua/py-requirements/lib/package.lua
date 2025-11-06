---@class py.reqs.package.Node
---@field value string
---@field col Range2

---@alias py.reqs.package.Status 'loading'|'invalid'|'valid'

---@class py.reqs.package.Info
---@field message string
---@field severity vim.diagnostic.Severity

---@class py.reqs.Package
---@field row integer 0-indexed
---@field name string
---@field comparison? string
---@field version? py.reqs.package.Node
---@field status py.reqs.package.Status
---@field versions string[]
local Package = {}
Package.__index = Package

---@param row integer
---@param name? string
---@param comparison? string
---@param version? py.reqs.package.Node
---@return py.reqs.Package?
function Package.new(row, name, comparison, version)
    if not name then
        return nil
    end
    local self = setmetatable({}, Package)
    self.row = row
    self.name = name
    self.comparison = comparison
    self.version = version
    self.status = 'loading'
    self.versions = {}
    return self
end

---@param versions py.reqs.pypi.Versions
function Package:set(versions)
    local values = versions.values
    if values then
        self.status = 'valid'
        self.versions = values
    else
        self.status = 'invalid'
    end
end

---@return string?
function Package:get()
    return self.version and self.version.value
end

---@return string?
function Package:latest()
    return self.versions[#self.versions]
end

---@return py.reqs.package.Info
function Package:info()
    if self.status == 'loading' then
        ---@type py.reqs.package.Info
        return {
            message = 'Loading',
            severity = vim.diagnostic.severity.INFO,
        }
    elseif self.status == 'invalid' then
        ---@type py.reqs.package.Info
        return {
            message = 'Error fetching library',
            severity = vim.diagnostic.severity.ERROR,
        }
    elseif self.status == 'valid' then
        if #self.versions == 0 then
            ---@type py.reqs.package.Info
            return {
                message = 'No versions found',
                severity = vim.diagnostic.severity.ERROR,
            }
        elseif
            self.version
            and not vim.tbl_contains(self.versions, self.version.value)
        then
            ---@type py.reqs.package.Info
            return {
                message = 'Invalid version',
                severity = vim.diagnostic.severity.ERROR,
            }
        else
            local latest = assert(self:latest())
            local severity = vim.diagnostic.severity.INFO
            if self.version and self.version.value ~= latest then
                severity = vim.diagnostic.severity.WARN
            end
            ---@type py.reqs.package.Info
            return {
                message = latest,
                severity = severity,
            }
        end
    else
        error(('Unhandled package status: %s'):format(self.status))
    end
end

return Package
