---@class py.reqs.State
---@field config py.reqs.Config
local M = {}

---@param default py.reqs.Config
---@param user py.reqs.UserConfig
function M.setup(default, user)
    M.config = vim.tbl_deep_extend('force', default, user)
end

return M
