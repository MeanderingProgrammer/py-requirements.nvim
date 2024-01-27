local cmp = require('py-requirements.cmp')
local core = require('py-requirements.core')
local state = require('py-requirements.state')

local M = {}

---@class UserConfig
---@field public enable_cmp? boolean
---@field public file_patterns? string[]

---@param opts UserConfig|nil
function M.setup(opts)
    ---@type Config
    local default_config = {
        enable_cmp = true,
        file_patterns = { 'requirements.txt' },
    }
    state.config = vim.tbl_deep_extend('force', default_config, opts or {})
    if state.config.enable_cmp then
        cmp.setup()
    end

    local events = { 'BufRead', 'TextChanged', 'TextChangedI', 'TextChangedP' }
    local group = vim.api.nvim_create_augroup('PyRequirements', { clear = true })
    local pattern = state.config.file_patterns
    vim.api.nvim_create_autocmd(events, {
        group = group,
        pattern = pattern,
        callback = core.update,
    })
end

return M
