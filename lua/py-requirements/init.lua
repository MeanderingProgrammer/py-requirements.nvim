local core = require('py-requirements.core')

local M = {}

function M.setup(opts)
    -- No options currently exist
    opts = opts or {}

    local group = vim.api.nvim_create_augroup('PyRequirements', { clear = true })
    local pattern = 'requirements.txt'
    vim.api.nvim_create_autocmd('BufRead', {
        group = group,
        pattern = pattern,
        callback = core.load,
    })
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'TextChangedP' }, {
        group = group,
        pattern = pattern,
        callback = core.update,
    })
end

return M
