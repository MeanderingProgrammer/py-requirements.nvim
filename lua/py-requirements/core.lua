local api = require('py-requirements.api')
local requirements = require('py-requirements.requirements')
local ui = require('py-requirements.ui')

local M = {}

local function handle()
    local buf = vim.api.nvim_get_current_buf()
    local modules = requirements.parse_modules(buf)
    for _, module in ipairs(modules) do
        module.versions = api.get_versions(module.name)
    end
    ui.display(buf, modules)
end

function M.load()
    handle()
end

function M.update()
    print('UPDATING')
    print('TODO')
end

return M
