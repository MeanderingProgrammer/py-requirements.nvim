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
    local characters = {}
    vim.list_extend(characters, { '.', '<', '>', '=', '^', '~', ' ' })
    vim.list_extend(characters, { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' })
    return characters
end

---@param row integer 0-indexed
---@return lsp.CompletionItem[]?
function M.completions(row)
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    if line == nil then
        return nil
    end

    local dependency = parser.dependency_string(line)
    if dependency == nil or dependency.comparison == nil then
        return nil
    end

    local node = dependency.version
    local versions = pypi.get_versions(dependency.name).values
    if node == nil or versions == nil then
        return nil
    end

    ---@type lsp.CompletionItem[]
    local result = {}
    ---@type lsp.Range
    local range = {
        ['start'] = { line = row, character = node.start_col },
        ['end'] = { line = row, character = node.end_col },
    }
    for i, version in ipairs(vim.fn.reverse(versions)) do
        ---@type lsp.CompletionItem
        local item = {
            label = version,
            kind = 12,
            textEdit = { newText = version, insert = range, replace = range },
            sortText = string.format('%04d', i),
        }
        result[#result + 1] = item
    end
    return result
end

return M
