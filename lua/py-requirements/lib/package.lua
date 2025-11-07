local pypi = require('py-requirements.lib.pypi')

---@alias py.reqs.package.Status 'loading'|'invalid'|'valid'

---@class py.reqs.Package
---@field row integer
---@field name string
---@field version? string
---@field cols? Range2
---@field status py.reqs.package.Status
---@field versions string[]
local Package = {}
Package.__index = Package

---@param source integer|string
---@param name? TSNode
---@param version? TSNode
---@return py.reqs.Package?
function Package.new(source, name, version)
    if not name then
        return nil
    end
    local self = setmetatable({}, Package)
    self.row = name:range()
    self.name = vim.treesitter.get_node_text(name, source)
    if version then
        local _, start_col, _, end_col = version:range()
        self.version = vim.treesitter.get_node_text(version, source)
        self.cols = { start_col, end_col }
    end
    self.status = 'loading'
    self.versions = {}
    return self
end

---@param row integer
---@param col integer
function Package:shift(row, col)
    self.row = self.row + row
    if self.cols then
        self.cols[1] = self.cols[1] + col
        self.cols[2] = self.cols[2] + col
    end
end

---@return py.reqs.pypi.Description
function Package:description()
    return pypi.get_description(self.name, self.version)
end

---@return string[]
function Package:update()
    local values = pypi.get_versions(self.name).values
    if values then
        self.status = 'valid'
        self.versions = values
    else
        self.status = 'invalid'
    end
    return self.versions
end

---@return string?
function Package:latest()
    return self.versions[#self.versions]
end

---@return vim.Diagnostic
function Package:diagnostic()
    local message = nil ---@type string?
    local severity = nil ---@type vim.diagnostic.Severity?
    if self.status == 'loading' then
        message = 'Loading'
        severity = vim.diagnostic.severity.INFO
    elseif self.status == 'invalid' then
        message = 'Error fetching versions'
        severity = vim.diagnostic.severity.ERROR
    elseif self.status == 'valid' then
        local latest = self:latest()
        if not latest then
            message = 'No versions found'
            severity = vim.diagnostic.severity.ERROR
        elseif not self:valid() then
            message = 'Invalid version'
            severity = vim.diagnostic.severity.ERROR
        else
            message = latest
            if self.version == latest then
                severity = vim.diagnostic.severity.INFO
            else
                severity = vim.diagnostic.severity.WARN
            end
        end
    end
    if not message or not severity then
        error(('Unhandled package status: %s'):format(self.status))
    end
    ---@type vim.Diagnostic
    return {
        source = 'py-requirements',
        col = 0,
        lnum = self.row,
        severity = severity,
        message = message,
    }
end

---@private
---@return boolean
function Package:valid()
    if not self.version then
        return true
    end
    return vim.tbl_contains(self.versions, self.version)
end

return Package
