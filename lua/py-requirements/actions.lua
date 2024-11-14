local parser = require('py-requirements.parser')
local pypi = require('py-requirements.pypi')
local ui = require('py-requirements.ui')

---@class py.reqs.Actions
local M = {}

---@param buf integer
---@param row integer?
function M.upgrade(buf, row)
    M.run_action(buf, row, function(dependency)
        dependency.versions = pypi.get_versions(dependency.name)
        ui.upgrade(buf, dependency)
    end)
end

---@param buf integer
---@param row integer
function M.show_description(buf, row)
    M.run_action(buf, row, function(dependency)
        local version = dependency.version and dependency.version.value
        local description = pypi.get_description(dependency.name, version)
        ui.show_description(description)
    end)
end

---@private
---@param buf integer
---@param row integer?
---@param callback fun(dependency: py.reqs.Dependency)
function M.run_action(buf, row, callback)
    local dependencies = parser.dependencies(buf)
    for _, dependency in ipairs(dependencies) do
        if row == nil or dependency.line_number == row then
            vim.schedule(function()
                callback(dependency)
            end)
        end
    end
end

return M
