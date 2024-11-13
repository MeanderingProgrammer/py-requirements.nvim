local shared = require('py-requirements.integrations.shared')

---@class py.requirements.Cmp: cmp.Source
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

function Source:complete(params, callback)
    local line = params.context.cursor_line
    vim.schedule(function()
        local _, versions = shared.get_versions(line)
        if versions == nil then
            callback(nil)
        else
            local items = Source.get_completion_items(versions)
            callback(items)
        end
    end)
end

---@private
---@param versions string[]
function Source.get_completion_items(versions)
    local result = {}
    for i, version in ipairs(vim.fn.reverse(versions)) do
        local item = {
            label = version,
            kind = 12,
            sortText = string.format('%04d', i),
            cmp = {
                kind_text = 'Version',
                kind_hl_group = 'Special',
            },
        }
        table.insert(result, item)
    end
    return result
end

---@class py.requirements.integration.Cmp
local M = {}

function M.setup()
    local ok, cmp = pcall(require, 'cmp')
    if ok then
        cmp.register_source(Source:get_debug_name(), Source)
    end
end

return M
