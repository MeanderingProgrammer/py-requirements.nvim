local cmp = require('py-requirements.cmp')
local core = require('py-requirements.core')

local M = {}

---@class UserConfig
---@field public enable_cmp? boolean
---@field public file_patterns? string[]

---@class State
---@field config UserConfig

---@type State
local state = {
    config = {
        enable_cmp = true,
        file_patterns = { 'requirements.txt' },
    },
}

---@param opts UserConfig|nil
function M.setup(opts)
    state.config = vim.tbl_deep_extend('force', state.config, opts or {})
    if M.get_config().enable_cmp then
        cmp.setup()
    end

    local group = vim.api.nvim_create_augroup('PyRequirements', { clear = true })
    local pattern = M.get_config().file_patterns
    vim.api.nvim_create_autocmd('BufRead', {
        group = group,
        pattern = pattern,
        callback = core.update,
    })
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'TextChangedP' }, {
        group = group,
        pattern = pattern,
        callback = core.update,
    })
end

---@return UserConfig
function M.get_config()
    return state.config
end

return M
