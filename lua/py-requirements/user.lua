local M = {}

---@return integer
function M.buffer()
    return vim.api.nvim_get_current_buf()
end

---@return integer
function M.row()
    -- Returned as row, column 2 element table, row is 1-indexed
    local cursor = vim.api.nvim_win_get_cursor(0)
    return cursor[1] - 1
end

return M
