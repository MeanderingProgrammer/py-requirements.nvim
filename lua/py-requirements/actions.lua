local parser = require('py-requirements.parser')
local pypi = require('py-requirements.pypi')
local ui = require('py-requirements.ui')

---@class py.requirements.Actions
local M = {}

---@param buf integer
---@param row integer?
function M.upgrade(buf, row)
    M.run_action(buf, row, function(module)
        module.versions = pypi.get_versions(module.name)
        ui.upgrade(buf, module)
    end)
end

---@param buf integer
---@param row integer
function M.show_description(buf, row)
    M.run_action(buf, row, function(module)
        local version = module.version and module.version.value
        local description = pypi.get_description(module.name, version)
        ui.show_description(description)
    end)
end

---@private
---@param buf integer
---@param row integer?
---@param callback fun(module: py.requirements.PythonModule)
function M.run_action(buf, row, callback)
    local modules = parser.modules(buf)
    for _, module in ipairs(modules) do
        if row == nil or module.line_number == row then
            vim.schedule(function()
                callback(module)
            end)
        end
    end
end

return M
