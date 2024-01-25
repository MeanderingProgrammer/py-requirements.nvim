local api = require('py-requirements.api')
local requirements = require('py-requirements.requirements')
local ui = require('py-requirements.ui')

local function handle()
    local buf = vim.api.nvim_get_current_buf()
    local modules = requirements.parse_modules(buf)
    for _, module in ipairs(modules) do
        api.get_versions(module.name, function(versions)
            module.versions = versions
            vim.schedule(function()
                ui.display(buf, modules)
            end)
        end)
    end
    ui.display(buf, modules)
end

local M = {}

function M.load()
    handle()
end

function M.update()
    print('UPDATING')
    print('TODO')
end

return M
