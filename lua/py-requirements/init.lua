---@class py.reqs.Init: py.reqs.Api
local M = {}

---@class (exact) py.reqs.Config
---@field enable_lsp boolean
---@field enable_cmp boolean
---@field index_url string
---@field extra_index_url? string
---@field file_patterns string[]
---@field diagnostic_opts py.reqs.diagnostic.Config
---@field float_opts vim.lsp.util.open_floating_preview.Opts
---@field filter py.reqs.version.filter.Config

---@class (exact) py.reqs.diagnostic.Config
---@field padding integer

---@class (exact) py.reqs.version.filter.Config
---@field final_release boolean
---@field yanked boolean

---@private
---@type py.reqs.Config
M.default = {
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
}

---@param opts? py.reqs.UserConfig
function M.setup(opts)
    require('py-requirements.state').setup(M.default, opts or {})
    require('py-requirements.manager').setup()
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('py-requirements.api')[key]
    end,
})
