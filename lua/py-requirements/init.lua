local actions = require('py-requirements.actions')
local cmp = require('py-requirements.cmp')
local core = require('py-requirements.core')
local state = require('py-requirements.state')
local user = require('py-requirements.user')

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

    local group = vim.api.nvim_create_augroup('PyRequirements', { clear = true })
    local pattern = state.config.file_patterns
    vim.api.nvim_create_autocmd({ 'BufRead' }, {
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

---Upgrade the dependency on the current line
function M.upgrade()
    actions.upgrade(user.row())
end

---Upgrade all dependencies in the buffer
function M.upgrade_all()
    actions.upgrade()
end

---Display PyPI package description in floating window
---@param opts? table
function M.open_float(opts)
    opts = opts or {}
    actions.open_float(user.row(), opts)
end

return M
