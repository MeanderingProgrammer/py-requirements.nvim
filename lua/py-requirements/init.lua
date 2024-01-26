local cmp = require('py-requirements.cmp')
local core = require('py-requirements.core')

local M = {}

---@class UserConfig
---@field public enable_cmp? boolean

---@param opts UserConfig|nil
function M.setup(opts)
    local default_opts = {
        enable_cmp = true,
    }
    opts = vim.tbl_deep_extend('force', default_opts, opts or {})

    if opts.enable_cmp then
        cmp.setup()
    end

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
