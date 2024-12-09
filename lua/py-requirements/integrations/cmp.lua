local shared = require('py-requirements.integrations.shared')

---@class py.reqs.Cmp: cmp.Source
local Source = {}

---@return string
function Source:get_debug_name()
    return 'py-requirements'
end

---@return boolean
function Source:is_available()
    return shared.enabled()
end

---@return string[]
function Source:get_trigger_characters()
    return shared.trigger_characters()
end

---@param params cmp.SourceCompletionApiParams
---@param callback fun(response?: lsp.CompletionItem[])
function Source:complete(params, callback)
    local line = params.context.cursor_line
    local row = params.context.cursor.row - 1
    vim.schedule(function()
        local node, versions = shared.get_versions(line)
        if node == nil or versions == nil then
            callback(nil)
        else
            local range = {
                ['start'] = { line = row, character = node.start_col },
                ['end'] = { line = row, character = node.end_col },
            }
            local items = Source.get_completion_items(versions, range)
            callback(items)
        end
    end)
end

---@private
---@param versions string[]
---@param range lsp.Range
---@return lsp.CompletionItem[]
function Source.get_completion_items(versions, range)
    local result = {}
    for i, version in ipairs(vim.fn.reverse(versions)) do
        ---@type lsp.CompletionItem
        local item = {
            label = version,
            kind = 12,
            textEdit = { newText = version, insert = range, replace = range },
            sortText = string.format('%04d', i),
            cmp = { kind_text = 'Version', kind_hl_group = 'Special' },
        }
        table.insert(result, item)
    end
    return result
end

---@class py.reqs.integ.Cmp
local M = {}

function M.setup()
    local ok, cmp = pcall(require, 'cmp')
    if ok then
        cmp.register_source(Source:get_debug_name(), Source)
    end
end

return M
