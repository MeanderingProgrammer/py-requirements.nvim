---@class py.requirements.VersionFilter
---@field public final_release boolean
---@field public yanked boolean

---@class py.requirements.Config
---@field public enable_cmp boolean
---@field public file_patterns string[]
---@field public float_opts vim.lsp.util.open_floating_preview.Opts
---@field public filter py.requirements.VersionFilter

---@class py.requirements.State
---@field config py.requirements.Config
local M = {}
return M
