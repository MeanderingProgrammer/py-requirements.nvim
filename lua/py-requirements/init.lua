local cmp = require('py-requirements.cmp')
local core = require('py-requirements.core')
local state = require('py-requirements.state')
local update = require('py-requirements.update')

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

    vim.api.nvim_create_autocmd('Filetype', {
        group = group,
        pattern = 'requirements',
        callback = function(ev)
            vim.api.nvim_buf_create_user_command(ev.buf, 'PyRequirementsUpdate', function(args)
                update.update(ev.buf, args.line1 - 1, args.line2)
            end, { range = true })
        end,
    })
end

return M
