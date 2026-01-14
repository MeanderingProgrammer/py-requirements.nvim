local pypi = require('py-requirements.lib.pypi')
local specifier = require('py-requirements.lib.specifier')

---@alias py.reqs.pack.Status 'loading'|'invalid'|'valid'

---@class py.reqs.pack.Spec
---@field cmp string
---@field version string
---@field cols Range2
local Spec = {}
Spec.__index = Spec

---@param source integer|string
---@param cmp TSNode
---@param version TSNode
---@return py.reqs.pack.Spec
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

---@class py.reqs.Pack
---@field row integer
---@field name string
---@field private specs py.reqs.pack.Spec[]
---@field private status py.reqs.pack.Status
---@field private versions string[]
local Pack = {}
Pack.__index = Pack

---@param source integer|string
---@param name TSNode
---@param cmps TSNode[]
---@param versions TSNode[]
---@return py.reqs.Pack
function Pack.new(source, name, cmps, versions)
    local self = setmetatable({}, Pack)
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
function Pack:shift(row, col)
    self.row = self.row + row
    for _, spec in ipairs(self.specs) do
        spec:shift(col)
    end
end

---@return py.reqs.pypi.Description
function Pack:description()
    local spec = self:spec()
    return pypi.get_description(self.name, spec and spec.version)
end

---@param callback fun(versions: string[])
function Pack:update(callback)
    pypi.get_versions(self.name, function(versions)
        local values = versions.values
        self.status = values and 'valid' or 'invalid'
        self.versions = values or {}
        callback(self.versions)
    end)
end

---@return py.reqs.pack.Spec?
function Pack:spec()
    return self.specs[#self.specs]
end

---@return string?
function Pack:latest()
    return self.versions[#self.versions]
end

---@return string, vim.diagnostic.Severity
function Pack:info()
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

    local matches = true
    for _, spec in ipairs(self.specs) do
        matches = matches and specifier.matches(latest, spec.cmp, spec.version)
    end
    if not matches then
        return latest, vim.diagnostic.severity.WARN
    end

    return latest, vim.diagnostic.severity.INFO
end

return Pack
