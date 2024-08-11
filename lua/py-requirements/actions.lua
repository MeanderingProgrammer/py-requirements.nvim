local api = require('py-requirements.api')
local parser = require('py-requirements.parser')
local ui = require('py-requirements.ui')
local user = require('py-requirements.user')

---@class py.requirements.Actions
local M = {}

---@param row integer?
function M.upgrade(row)
    M.run_action(row, function(buf, module)
        module.versions = api.get_versions(module.name)
        ui.upgrade(buf, module)
    end)
end

---@param row integer
function M.show_description(row)
    M.run_action(row, function(_, module)
        local version = module.version and module.version.value
        local description = api.get_description(module.name, version)
        ui.show_description(description)
    end)
end

---@private
---@param row integer?
---@param callback fun(buf: integer, module: py.requirements.PythonModule)
function M.run_action(row, callback)
    local buf = user.buffer()
    local modules = parser.parse_modules(buf)
    for _, module in ipairs(modules) do
        if row == nil or module.line_number == row then
            vim.schedule(function()
                callback(buf, module)
            end)
        end
    end
end

return M
