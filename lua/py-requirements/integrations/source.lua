local manager = require('py-requirements.manager')
local parser = require('py-requirements.parser')
local pypi = require('py-requirements.pypi')

---@class py.reqs.Source
local M = {}

---@return boolean
function M.enabled()
    return manager.active(vim.api.nvim_get_current_buf())
end

---@return string[]
function M.trigger_characters()
    ---@type string[]
    return { '.', '<', '>', '=', '^', '~', ' ' }
end

---@param row integer 0-indexed
---@return lsp.CompletionItem[]?
function M.completions(row)
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    if line == nil then
        return nil
    end

    local package = parser.line(line)
    if not package or not package.comparison then
        return nil
    end

    local node = package.version
    local versions = pypi.get_versions(package.name).values
    if not node or not versions then
        return nil
    end

    local result = {} ---@type lsp.CompletionItem[]
    ---@type lsp.Range
    local range = {
        ['start'] = { line = row, character = node.col[1] },
        ['end'] = { line = row, character = node.col[2] },
    }
    for i, version in ipairs(vim.fn.reverse(versions)) do
        ---@type lsp.CompletionItem
        local item = {
            label = version,
            kind = 12,
            textEdit = { newText = version, insert = range, replace = range },
            sortText = ('%04d'):format(i),
        }
        result[#result + 1] = item
    end
    return result
end

return M
