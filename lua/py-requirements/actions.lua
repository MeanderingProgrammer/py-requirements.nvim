local api = require('py-requirements.api')
local requirements = require('py-requirements.requirements')
local ui = require('py-requirements.ui')
local user = require('py-requirements.user')

local M = {}

---@param row integer|nil
---@param callback fun(buf: integer, module: PythonModule)
local function run_action(row, callback)
    local buf = user.buffer()
    local modules = requirements.parse_modules(buf)
    for _, module in ipairs(modules) do
        if row == nil or module.line_number == row then
            vim.schedule(function()
                callback(buf, module)
            end)
        end
    end
end

---@param row integer|nil
function M.upgrade(row)
    run_action(row, function(buf, module)
        module.versions = api.get_versions(module.name)
        ui.upgrade(buf, module)
    end)
end

---@param row integer
function M.show_description(row)
    run_action(row, function(_, module)
        module.description = api.get_description(module.name, module.version and module.version.value)
        ui.show_description(module)
    end)
end

return M
