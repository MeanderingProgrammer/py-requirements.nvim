local manager = require('py-requirements.manager')
local parser = require('py-requirements.parser')
local util = require('py-requirements.lib.util')

---@class py.reqs.Source
local M = {}

---@return boolean
function M.enabled()
    return manager.active(util.buffer())
end

---@return string[]
function M.trigger_characters()
    ---@type string[]
    return { '.', '<', '>', '=', '^', '~', ' ' }
end

---@param row integer 0-indexed
---@param callback fun(items?: lsp.CompletionItem[])
function M.items(row, callback)
    local buf = util.buffer()
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
    if not line then
        callback(nil)
        return
    end

    local pack = parser.line(buf, line)
    if not pack then
        callback(nil)
        return
    end

    local spec = pack:spec()
    if not spec then
        callback(nil)
        return
    end

    ---@type lsp.Range
    local range = {
        ['start'] = { line = row, character = spec.cols[1] },
        ['end'] = { line = row, character = spec.cols[2] },
    }

    pack:update(function(versions)
        local result = {} ---@type lsp.CompletionItem[]
        for i, version in ipairs(vim.fn.reverse(versions)) do
            result[#result + 1] = {
                label = version,
                kind = 12,
                textEdit = {
                    newText = version,
                    insert = range,
                    replace = range,
                },
                sortText = ('%04d'):format(i),
            }
        end
        callback(#result > 0 and result or nil)
    end)
end

return M
