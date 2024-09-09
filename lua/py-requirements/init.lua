---@class py.requirements.Init: py.requirements.Api
local M = {}

---@class (exact) py.requirements.UserVersionFilter
---@field public final_release? boolean
---@field public yanked? boolean

---@class (exact) py.requirements.UserConfig
---@field public enable_cmp? boolean
---@field public index_url? string
---@field public extra_index_url? string
---@field public file_patterns? string[]
---@field public float_opts? table
---@field public filter? py.requirements.UserVersionFilter
---@field public requirement_query? string
---@field public module_query? string

---@private
---@type py.requirements.Config
M.default_config = {
    enable_cmp = true,
    index_url = 'https://pypi.org/simple/',
    extra_index_url = nil,
    file_patterns = { 'requirements.txt' },
    float_opts = { border = 'rounded' },
    filter = {
        final_release = false,
        yanked = true,
    },
    requirement_query = '(requirement) @requirement',
    module_query = [[
        (requirement (package) @name)
        (version_spec (version_cmp) @cmp)
        (version_spec (version) @version)
    ]],
}

---@param opts? py.requirements.UserConfig
function M.setup(opts)
    local state = require('py-requirements.state')
    state.setup(M.default_config, opts or {})
    if state.config.enable_cmp then
        require('py-requirements.cmp').setup()
    end
    require('py-requirements.manager').setup()
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('py-requirements.api')[key]
    end,
})
