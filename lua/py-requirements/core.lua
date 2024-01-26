local api = require('py-requirements.api')
local requirements = require('py-requirements.requirements')
local ui = require('py-requirements.ui')

local function handle()
    local buf = vim.api.nvim_get_current_buf()
    local modules = requirements.parse_modules(buf)
    for _, module in ipairs(modules) do
        local versions = api.get_versions(module.name)
        module.versions = versions
    end
    ui.display(buf, modules)
end

local M = {}

function M.load()
    vim.schedule(handle)
end

function M.update()
    vim.schedule(handle)
end

return M
