---@module 'blink.cmp'

local shared = require('py-requirements.integrations.shared')

---@class py.reqs.Blink: blink.cmp.Source
local Source = {}
Source.__index = Source

---@return blink.cmp.Source
function Source.new()
    return setmetatable({}, Source)
end

---@return boolean
function Source:enabled()
    return shared.enabled()
end

---@return string[]
function Source:get_trigger_characters()
    return shared.trigger_characters()
end

---@param context blink.cmp.Context
---@param callback fun(response?: blink.cmp.CompletionResponse)
function Source:get_completions(context, callback)
    local node, versions = shared.get_versions(context.line)
    if node == nil or versions == nil then
        callback(nil)
    else
        local row = context.cursor[1] - 1
        local range = {
            ['start'] = { line = row, character = node.start_col },
            ['end'] = { line = row, character = node.end_col },
        }
        local items = Source.get_completion_items(versions, range)
        callback({
            is_incomplete_forward = false,
            is_incomplete_backward = false,
            context = context,
            items = items,
        })
    end
end

---@private
---@param versions string[]
---@param range lsp.Range
---@return lsp.CompletionItem[]
function Source.get_completion_items(versions, range)
    local result = {}
    for _, version in ipairs(versions) do
        ---@type lsp.CompletionItem
        local item = {
            label = version,
            kind = 12,
            textEdit = { newText = version, insert = range, replace = range },
        }
        table.insert(result, item)
    end
    return result
end

return Source
