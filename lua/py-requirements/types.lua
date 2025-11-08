---@meta

---@class (exact) py.reqs.UserConfig
---@field index_url? string
---@field extra_index_url? string
---@field file_patterns? string[]
---@field diagnostic_opts? py.reqs.diagnostic.UserConfig
---@field float_opts? vim.lsp.util.open_floating_preview.Opts
---@field filter? py.reqs.version.filter.UserConfig
---@field enable_lsp? boolean

---@class (exact) py.reqs.diagnostic.UserConfig
---@field padding? integer

---@class (exact) py.reqs.version.filter.UserConfig
---@field final_release? boolean
---@field yanked? boolean
