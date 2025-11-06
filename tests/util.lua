---@class py.reqs.test.Util
local M = {}

---@param opts py.reqs.UserConfig
---@param file? string
function M.setup(opts, file)
    require('py-requirements').setup(opts)
    if file then
        vim.cmd('e ' .. file)
        vim.wait(0)
    end
end

---@param name string
---@param lines string[]
---@return integer
function M.create_file(name, lines)
    local buf = vim.fn.bufnr(name, true)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    return buf
end

return M
