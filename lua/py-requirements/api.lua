local curl = require('plenary.curl')

---@class ModuleVersions
---@field status ModuleStatus
---@field values string[]

---@class ModuleDescription
---@field content string[]
---@field content_type? string

---@class Cache
---@field versions table<string,ModuleVersions>
---@field descriptions table<string,ModuleDescription>

---@type Cache
local cache = {
    versions = {},
    descriptions = {},
}

local M = {}

---@enum ModuleStatus
M.ModuleStatus = {
    LOADING = 1,
    INVALID = 2,
    VALID = 3,
}

---@type ModuleVersions
M.INITIAL = { status = M.ModuleStatus.LOADING, values = {} }

---@type ModuleVersions
M.FAILED = { status = M.ModuleStatus.INVALID, values = {} }

---@param path string
---@param headers table<string,string>
---@return table|nil
local function call_pypi(path, headers)
    local result = curl.get(string.format('https://pypi.org/%s', path), {
        headers = vim.tbl_deep_extend('force', {
            ['User-Agent'] = 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)',
        }, headers),
        raw = { '--location' },
    })
    if result == nil or not vim.tbl_contains({ 200, 301 }, result.status) then
        return nil
    else
        return vim.json.decode(result.body)
    end
end

---@param name string
---@return ModuleVersions
function M.get_versions(name)
    local cached_versions = cache.versions[name]
    if cached_versions then
        return cached_versions
    end

    -- curl --location \
    --   -H 'Accept: application/vnd.pypi.simple.v1+json' \
    --   -A 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)' \
    --   https://pypi.org/simple/{name}/
    local result = call_pypi(string.format('simple/%s/', name:lower()), {
        Accept = 'application/vnd.pypi.simple.v1+json',
    })

    if result == nil or result.versions == nil then
        return M.FAILED
    end

    local versions = { status = M.ModuleStatus.VALID, values = result.versions }
    cache.versions[name] = versions
    return versions
end

---@param module_name string
---@param version? string
---@return ModuleDescription
function M.get_description(module_name, version)
    local cached_description = cache.descriptions[module_name]
    if cached_description then
        return cached_description
    end

    local path
    if version then
        path = string.format('pypi/%s/%s/json', module_name:lower(), version)
    else
        path = string.format('pypi/%s/json', module_name:lower())
    end

    -- curl --location \
    --   -A 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)' \
    --   https://pypi.org/pypi/{module_name}/{version?}/json
    local result = call_pypi(path, {})

    if result == nil or result.info.description == nil then
        return { content = {} }
    end

    local description = {
        content = vim.split(result.info.description, '\n'),
        content_type = result.info.description_content_type,
    }
    cache.descriptions[module_name] = description
    return description
end

return M
