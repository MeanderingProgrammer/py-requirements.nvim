local curl = require('plenary.curl')

---@class ModuleVersions
---@field status ModuleStatus
---@field values string[]

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

---@return ModuleVersions
function M.parse_versions(result)
    if result == nil or not vim.tbl_contains({ 200, 301 }, result.status) then
        return M.FAILED
    end
    local json = vim.json.decode(result.body)
    if json == nil or json.versions == nil then
        return M.FAILED
    end
    ---@type ModuleVersions
    return { status = M.ModuleStatus.VALID, values = json.versions }
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
    local result = curl.get(string.format('https://pypi.org/simple/%s/', name:lower()), {
        headers = {
            ['Accept'] = 'application/vnd.pypi.simple.v1+json',
            ['User-Agent'] = 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)',
        },
        raw = { '--location' },
    })
    local versions = M.parse_versions(result)
    cache.versions[name] = versions
    return versions
end

---@class ModuleDescription
---@field content string[]
---@field content_type? string

---@return ModuleDescription
function M.parse_description(result)
    if result == nil or not vim.tbl_contains({ 200, 301 }, result.status) then
        return { content = {} }
    end
    local json = vim.json.decode(result.body)
    if json == nil or json.info.description == nil then
        return { content = {} }
    end
    return {
        content = vim.split(json.info.description, '\n'),
        content_type = json.info.description_content_type,
    }
end

---@param module PythonModule
---@return ModuleDescription
function M.get_description(module)
    local name = module.name
    local cached_description = cache.descriptions[name]
    if cached_description then
        return cached_description
    end

    local url
    if module.version then
        url = string.format('https://pypi.org/pypi/%s/%s/json', name:lower(), module.version.value)
    else
        url = string.format('https://pypi.org/pypi/%s/json', name:lower())
    end

    -- curl --location \
    --   -H 'Accept: application/vnd.pypi.simple.v1+json' \
    --   -A 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)' \
    --   https://pypi.org/pypi/{name}/{version?}/json
    local result = curl.get(url, {
        headers = {
            ['User-Agent'] = 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)',
        },
        raw = { '--location' },
    })
    local description = M.parse_description(result)
    cache.descriptions[name] = description
    return description
end

return M
