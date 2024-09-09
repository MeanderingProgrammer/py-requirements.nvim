local actions = require('py-requirements.actions')

---@return integer
local function buffer()
    return vim.api.nvim_get_current_buf()
end

---@return integer
local function row()
    -- Returned as { row, column } table, row is 1-indexed
    return vim.api.nvim_win_get_cursor(0)[1] - 1
end

---@class py.requirements.Api
local M = {}

---Upgrade the dependency on the current line
function M.upgrade()
    actions.upgrade(buffer(), row())
end

---Upgrade all dependencies in the buffer
function M.upgrade_all()
    actions.upgrade(buffer())
end

---Display PyPI package description in floating window
function M.show_description()
    actions.show_description(buffer(), row())
end

return M
