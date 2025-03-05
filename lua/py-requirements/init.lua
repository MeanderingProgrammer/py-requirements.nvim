---@class py.reqs.Init: py.reqs.Api
local M = {}

---@class (exact) py.reqs.UserVersionFilter
---@field public final_release? boolean
---@field public yanked? boolean

---@class (exact) py.reqs.UserDiagnosticOpts
---@field public padding? integer

---@class (exact) py.reqs.UserConfig
---@field public enable_lsp? boolean
---@field public enable_cmp? boolean
---@field public index_url? string
---@field public extra_index_url? string
---@field public file_patterns? string[]
---@field public diagnostic_opts? py.reqs.UserDiagnosticOpts
---@field public float_opts? vim.lsp.util.open_floating_preview.Opts
---@field public filter? py.reqs.UserVersionFilter
---@field public requirement_query? string
---@field public dependency_query? string

---@private
---@type py.reqs.Config
M.default_config = {
    enable_lsp = true,
    enable_cmp = false,
    index_url = 'https://pypi.org/simple/',
    extra_index_url = nil,
    file_patterns = { 'requirements.txt' },
    diagnostic_opts = { padding = 5 },
    float_opts = { border = 'rounded' },
    filter = {
        final_release = false,
        yanked = true,
    },
    requirement_query = '(requirement) @requirement',
    dependency_query = [[
        (requirement (package) @name)
        (version_spec (version_cmp) @cmp)
        (version_spec (version) @version)
    ]],
}

---@param opts? py.reqs.UserConfig
function M.setup(opts)
    local state = require('py-requirements.state')
    state.setup(M.default_config, opts or {})
    require('py-requirements.manager').setup()
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('py-requirements.api')[key]
    end,
})
