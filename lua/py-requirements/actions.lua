local api = require('py-requirements.api')
local requirements = require('py-requirements.requirements')
local ui = require('py-requirements.ui')
local user = require('py-requirements.user')

local M = {}

---@param row integer|nil
function M.upgrade(row)
    local buf = user.buffer()
    local modules = requirements.parse_modules(buf)
    for _, module in ipairs(modules) do
        if row == nil or module.line_number == row then
            vim.schedule(function()
                module.versions = api.get_versions(module.name)
                ui.upgrade(buf, module)
            end)
        end
    end
end

return M
