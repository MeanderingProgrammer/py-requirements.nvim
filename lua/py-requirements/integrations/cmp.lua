local source = require('py-requirements.integrations.source')

---@class py.reqs.cmp.Source: cmp.Source
local Source = {}

---@return string
function Source:get_debug_name()
    return 'py-requirements'
end

---@return boolean
function Source:is_available()
    return source.enabled()
end

---@return string[]
function Source:get_trigger_characters()
    return source.trigger_characters()
end

---@param params cmp.SourceCompletionApiParams
---@param callback fun(response?: lsp.CompletionItem[])
function Source:complete(params, callback)
    -- nvim_win_get_cursor: (1,0)-indexed
    -- nvim-cmp col + 1   : (1,1)-indexed
    local row = params.context.cursor.row - 1
    vim.schedule(function()
        local items = source.completions(row)
        if items == nil then
            callback(nil)
        else
            callback(Source.add_cmp(items))
        end
    end)
end

---@private
---@param items lsp.Range
---@return lsp.CompletionItem[]
function Source.add_cmp(items)
    local result = {}
    for _, item in ipairs(items) do
        item.cmp = { kind_text = 'Version', kind_hl_group = 'Special' }
        table.insert(result, item)
    end
    return result
end

---@class py.reqs.integ.Cmp
---@field private registered boolean
local M = {
    registered = false,
}

function M.setup()
    if M.registered then
        return
    end
    local ok, cmp = pcall(require, 'cmp')
    if ok then
        cmp.register_source(Source:get_debug_name(), Source)
    end
    M.registered = true
end

return M
