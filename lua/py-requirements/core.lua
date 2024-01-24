local requirements = require('py-requirements.requirements')

local M = {}

local function handle()
    local buf = vim.api.nvim_get_current_buf()
    local modules = requirements.parse_modules(buf)
    print('MODULES')
    for _, module in ipairs(modules) do
        P(module)
    end
end

function M.load()
    print('LOADING')
    handle()
end

function M.update()
    print('UPDATING')
    print('TODO')
end

return M
