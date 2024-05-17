---@class VersionFilter
---@field public final_release boolean
---@field public yanked boolean

---@class Config
---@field public enable_cmp boolean
---@field public file_patterns string[]
---@field public float_opts vim.lsp.util.open_floating_preview.Opts
---@field public filter VersionFilter

---@class State
---@field config Config
local state = {}
return state
