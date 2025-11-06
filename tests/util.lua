---@module 'luassert'

---@class py.reqs.test.Util
local M = {}

---@param opts py.reqs.UserConfig
function M.setup(opts)
    require('py-requirements').setup(opts)
end

---@alias py.reqs.test.Filetype 'requirements'

---@param filetype py.reqs.test.Filetype
---@param lines string[]
---@return integer
function M.create(filetype, lines)
    ---@type table<py.reqs.test.Filetype, string>
    local names = {
        ['requirements'] = 'requirements.txt',
    }
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, names[filetype])
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value('filetype', filetype, { buf = buf })
    return buf
end

---@param buf integer
function M.delete(buf)
    vim.api.nvim_buf_delete(buf, { force = true })
end

return M
