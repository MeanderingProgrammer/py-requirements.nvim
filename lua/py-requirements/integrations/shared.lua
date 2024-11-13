local manager = require('py-requirements.manager')
local parser = require('py-requirements.parser')
local pypi = require('py-requirements.pypi')

---@class py.requirements.integration.Shared
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

---@param line string
---@return py.requirements.Node?, py.requirements.ModuleVersions?
function M.get_versions(line)
    local module = parser.module_string(line)
    if module == nil or module.comparison == nil then
        return nil, nil
    else
        return module.version, pypi.get_versions(module.name)
    end
end

return M
