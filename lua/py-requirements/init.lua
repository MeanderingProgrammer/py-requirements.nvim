local actions = require('py-requirements.actions')
local cmp = require('py-requirements.cmp')
local core = require('py-requirements.core')
local state = require('py-requirements.state')
local user = require('py-requirements.user')

---@class py.requirements.Init
local M = {}

---@class py.requirements.UserVersionFilter
---@field public final_release? boolean
---@field public yanked? boolean

---@class py.requirements.UserConfig
---@field public enable_cmp? boolean
---@field public file_patterns? string[]
---@field public float_opts? table
---@field public filter? py.requirements.UserVersionFilter

---@param opts? py.requirements.UserConfig
function M.setup(opts)
    ---@type py.requirements.Config
    local default_config = {
        enable_cmp = true,
        file_patterns = { 'requirements.txt' },
        float_opts = { border = 'rounded' },
        filter = {
            final_release = false,
            yanked = true,
        },
    }
    state.config = vim.tbl_deep_extend('force', default_config, opts or {})
    if state.config.enable_cmp then
        cmp.setup()
    end

    local group = vim.api.nvim_create_augroup('PyRequirements', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufRead' }, {
        group = group,
        callback = core.load,
    })
    vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
        group = group,
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
function M.show_description()
    actions.show_description(user.row())
end

return M
