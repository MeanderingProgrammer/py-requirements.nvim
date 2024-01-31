local api = require('py-requirements.api')
local parser = require('py-requirements.parser')
local state = require('py-requirements.state')
local ui = require('py-requirements.ui')
local user = require('py-requirements.user')

---@param show_initial boolean
local function handle(show_initial)
    local buf = user.buffer()
    local modules = parser.parse_modules(buf)
    local max_len = parser.max_len(buf, modules)
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

---@return boolean
function M.active()
    local file_name = vim.fn.expand('%:t')
    for _, file_pattern in ipairs(state.config.file_patterns) do
        local match = vim.regex(file_pattern):match_str(file_name)
        if match and match == 0 then
            return true
        end
    end
    return false
end

function M.load()
    if M.active() then
        handle(true)
    end
end

function M.update()
    if M.active() then
        handle(false)
    end
end

return M
