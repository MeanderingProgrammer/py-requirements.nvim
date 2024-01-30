local api = require('py-requirements.api')
local requirements = require('py-requirements.requirements')
local ui = require('py-requirements.ui')
local user = require('py-requirements.user')

---@param show_initial boolean
local function handle(show_initial)
    local buf = user.buffer()
    local modules = requirements.parse_modules(buf)
    local max_len = requirements.max_len(buf, modules)
    if show_initial then
        ui.display(buf, modules, max_len)
    end
    for _, module in ipairs(modules) do
        vim.schedule(function()
            module.versions = api.get_versions(module.name)
        end)
    end
    vim.schedule(function()
        ui.display(buf, modules, max_len)
    end)
end

local M = {}

function M.load()
    handle(true)
end

function M.update()
    handle(false)
end

return M
