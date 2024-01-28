local api = require('py-requirements.api')
local requirements = require('py-requirements.requirements')
local state = require('py-requirements.state')

---@param module PythonModule
local function get_completion_items(module)
    local versions = api.get_versions(module.name)
    local result = {}
    for _, version in ipairs(versions) do
        local item = {
            label = version,
            kind = 12,
            cmp = {
                kind_text = 'Version',
                kind_hl_group = 'Special',
            },
        }
        table.insert(result, item)
    end
    return result
end

local M = {}

---@return boolean
function M:is_available()
    local file_patterns = state.config.file_patterns
    return vim.tbl_contains(file_patterns, vim.fn.expand('%:t'))
end

---@return string
function M:get_debug_name()
    return 'py-requirements'
end

---@return string[]
function M:get_trigger_characters()
    local characters = {}
    vim.list_extend(characters, { '.', '<', '>', '=', '^', '~', ' ' })
    vim.list_extend(characters, { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' })
    return characters
end

function M:complete(params, callback)
    --Adding a 0 at the end as if we started typing a version number
    local line = params.context.cursor_line .. '0'
    local module = requirements.parse_module_string(line)
    if module == nil or module.kind == nil then
        callback(nil)
    else
        vim.schedule(function()
            local items = get_completion_items(module)
            callback(items)
        end)
    end
end

function M.setup()
    require('cmp').register_source('py-requirements', M)
end

return M
