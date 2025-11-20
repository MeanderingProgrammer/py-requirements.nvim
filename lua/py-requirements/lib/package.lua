local pypi = require('py-requirements.lib.pypi')

---@alias py.reqs.package.Status 'loading'|'invalid'|'valid'

---@class py.reqs.package.Spec
---@field cmp string
---@field version string
---@field cols Range2
local Spec = {}
Spec.__index = Spec

---@param source integer|string
---@param cmp TSNode
---@param version TSNode
---@return py.reqs.package.Spec
function Spec.new(source, cmp, version)
    local self = setmetatable({}, Spec)
    self.cmp = vim.treesitter.get_node_text(cmp, source)
    self.version = vim.treesitter.get_node_text(version, source)
    local _, start_col, _, end_col = version:range()
    self.cols = { start_col, end_col }
    return self
end

---@param col? integer
function Spec:shift(col)
    if col then
        self.cols[1] = self.cols[1] + col
        self.cols[2] = self.cols[2] + col
    else
        self.cols = nil
    end
end

---@class py.reqs.Package
---@field row integer
---@field name string
---@field private specs py.reqs.package.Spec[]
---@field private status py.reqs.package.Status
---@field private versions string[]
local Package = {}
Package.__index = Package

---@param source integer|string
---@param name TSNode
---@param cmps TSNode[]
---@param versions TSNode[]
---@return py.reqs.Package
function Package.new(source, name, cmps, versions)
    local self = setmetatable({}, Package)
    self.row = name:range()
    self.name = vim.treesitter.get_node_text(name, source)
    self.specs = {}
    for i = 1, math.min(#cmps, #versions) do
        self.specs[#self.specs + 1] = Spec.new(source, cmps[i], versions[i])
    end
    self.status = 'loading'
    self.versions = {}
    return self
end

---@param row integer
---@param col? integer
function Package:shift(row, col)
    self.row = self.row + row
    for _, spec in ipairs(self.specs) do
        spec:shift(col)
    end
end

---@return py.reqs.pypi.Description
function Package:description()
    local spec = self:spec()
    return pypi.get_description(self.name, spec and spec.version)
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

---@return py.reqs.package.Spec?
function Package:spec()
    return self.specs[#self.specs]
end

---@return string?
function Package:latest()
    return self.versions[#self.versions]
end

---@return string, vim.diagnostic.Severity
function Package:info()
    if self.status == 'loading' then
        return 'Loading', vim.diagnostic.severity.INFO
    end

    if self.status == 'invalid' then
        return 'Error fetching versions', vim.diagnostic.severity.ERROR
    end

    assert(self.status == 'valid', ('invalid status: %s'):format(self.status))
    local latest = self:latest()
    if not latest then
        return 'No versions found', vim.diagnostic.severity.ERROR
    end

    local spec = self:spec()
    if not spec then
        return latest, vim.diagnostic.severity.WARN
    end

    if spec.version == latest then
        return latest, vim.diagnostic.severity.INFO
    end

    local matches = vim.tbl_contains(self.versions, spec.version)
    local equality = vim.tbl_contains({ '==', '===' }, spec.cmp)
    if not matches and equality then
        return 'Invalid version', vim.diagnostic.severity.ERROR
    end

    return latest, vim.diagnostic.severity.WARN
end

return Package
