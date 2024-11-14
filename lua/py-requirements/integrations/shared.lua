local manager = require('py-requirements.manager')
local parser = require('py-requirements.parser')
local pypi = require('py-requirements.pypi')

---@class py.reqs.integ.Shared
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
---@return py.reqs.Node?, string[]?
function M.get_versions(line)
    local dependency = parser.dependency_string(line)
    if dependency == nil or dependency.comparison == nil then
        return nil, nil
    else
        return dependency.version, pypi.get_versions(dependency.name).values
    end
end

return M
