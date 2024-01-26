local api = require('py-requirements.api')
local requirements = require('py-requirements.requirements')

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
    return vim.fn.expand('%:t') == 'requirements.txt'
end

---@return string
function M:get_debug_name()
    return 'py-requirements'
end

---@return string[]
function M:get_trigger_characters()
    local characters = {}
    vim.list_extend(characters, { '.', '<', '>', '=', '^', '~' })
    vim.list_extend(characters, { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' })
    return characters
end

function M:complete(params, callback)
    local line = params.context.cursor_line
    local module = requirements.parse_module(-1, line)
    if module == nil then
        callback()
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
