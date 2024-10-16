local manager = require('py-requirements.manager')
local parser = require('py-requirements.parser')
local pypi = require('py-requirements.pypi')

---@class py.requirements.Cmp: cmp.Source
local M = {}

---@return boolean
function M:is_available()
    return manager.active(vim.api.nvim_get_current_buf())
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
    local line = params.context.cursor_line
    local module = parser.module_string(line)
    if module == nil or module.comparison == nil then
        callback(nil)
    else
        vim.schedule(function()
            local items = M.get_completion_items(module)
            callback(items)
        end)
    end
end

---@private
---@param module py.requirements.PythonModule
function M.get_completion_items(module)
    local versions = pypi.get_versions(module.name)
    local version_values = vim.fn.reverse(versions.values)
    local result = {}
    for i, version in ipairs(version_values) do
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

function M.setup()
    local ok, cmp = pcall(require, 'cmp')
    if ok then
        cmp.register_source(M:get_debug_name(), M)
    end
end

return M
