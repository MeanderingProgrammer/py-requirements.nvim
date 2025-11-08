local actions = require('py-requirements.actions')

---@class py.reqs.Api
local M = {}

---Upgrade the dependency on the current line
function M.upgrade()
    actions.upgrade(false)
end

---Upgrade all dependencies in the buffer
function M.upgrade_all()
    actions.upgrade(true)
end

---Display PyPI package description in floating window
function M.show_description()
    actions.show_description()
end

return M
