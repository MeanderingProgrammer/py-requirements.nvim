---@class (exact) py.reqs.VersionFilter
---@field public final_release boolean
---@field public yanked boolean

---@class (exact) py.reqs.DiagnosticOpts
---@field public padding integer

---@class (exact) py.reqs.Config
---@field public enable_cmp boolean
---@field public index_url string
---@field public extra_index_url? string
---@field public file_patterns string[]
---@field public diagnostic_opts py.reqs.DiagnosticOpts
---@field public float_opts vim.lsp.util.open_floating_preview.Opts
---@field public filter py.reqs.VersionFilter
---@field public requirement_query string
---@field public dependency_query string

---@class py.reqs.State
---@field config py.reqs.Config
---@field requirement_query vim.treesitter.Query
---@field dependency_query vim.treesitter.Query
local M = {}

---@param default_config py.reqs.Config
---@param user_config py.reqs.UserConfig
function M.setup(default_config, user_config)
    M.config = vim.tbl_deep_extend('force', default_config, user_config)
    M.requirement_query = vim.treesitter.query.parse('requirements', M.config.requirement_query)
    M.dependency_query = vim.treesitter.query.parse('requirements', M.config.dependency_query)
end

return M
