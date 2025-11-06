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
        local items = source.items(row)
        if not items then
            callback(nil)
        else
            for _, item in ipairs(items) do
                item.cmp = { kind_text = 'Version', kind_hl_group = 'Special' }
            end
            callback(items)
        end
    end)
end

---@class py.reqs.integ.Cmp
local M = {}

---@private
---@type boolean
M.initialized = false

function M.setup()
    if M.initialized then
        return
    end
    M.initialized = true
    local has_cmp, cmp = pcall(require, 'cmp')
    if not has_cmp or not cmp then
        return
    end
    pcall(cmp.register_source, Source:get_debug_name(), Source)
end

return M
