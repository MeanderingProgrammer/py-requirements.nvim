---@class (exact) py.requirements.VersionFilter
---@field public final_release boolean
---@field public yanked boolean

---@class (exact) py.requirements.Config
---@field public enable_cmp boolean
---@field public index_url string
---@field public extra_index_url? string
---@field public file_patterns string[]
---@field public float_opts vim.lsp.util.open_floating_preview.Opts
---@field public filter py.requirements.VersionFilter
---@field public requirement_query string
---@field public module_query string

---@class py.requirements.State
---@field config py.requirements.Config
---@field requirement_query vim.treesitter.Query
---@field module_query vim.treesitter.Query
local M = {}

---@param default_config py.requirements.Config
---@param user_config py.requirements.UserConfig
function M.setup(default_config, user_config)
    M.config = vim.tbl_deep_extend('force', default_config, user_config)
    M.requirement_query = vim.treesitter.query.parse('requirements', M.config.requirement_query)
    M.module_query = vim.treesitter.query.parse('requirements', M.config.module_query)
end

return M
