---@module 'blink.cmp'

local shared = require('py-requirements.integrations.shared')

---@class py.requirements.Blink: blink.cmp.Source
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
    local version, versions = shared.get_versions(context.line)
    if version == nil or versions == nil then
        callback(nil)
    else
        local line = context.cursor[1] - 1
        local range = {
            ['start'] = { line = line, character = version.start_col },
            ['end'] = { line = line, character = version.end_col },
        }
        local items = Source.get_completion_items(range, versions)
        callback({
            is_incomplete_forward = true,
            is_incomplete_backward = true,
            context = context,
            items = items,
        })
    end
end

---@private
---@param range lsp.Range
---@param versions py.requirements.ModuleVersions
---@return lsp.CompletionItem[]
function Source.get_completion_items(range, versions)
    local result = {}
    for _, version in ipairs(versions.values) do
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
