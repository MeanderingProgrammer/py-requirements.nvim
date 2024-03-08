local curl = require('plenary.curl')

---@class ModuleVersions
---@field status ModuleStatus
---@field values string[]

---@class ModuleDescription
---@field content? string[]
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
---@param filter VersionFilter
---@return ModuleVersions
function M.get_versions(name, filter)
    local cached_versions = cache.versions[name]
    if cached_versions then
        return cached_versions
    end

    -- curl --location \
    --   -H 'Accept: application/vnd.pypi.simple.v1+json' \
    --   -A 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)' \
    --   https://pypi.org/simple/{name}/
    local result = call_pypi(string.format('simple/%s/', name:lower()), {
        ['Accept'] = 'application/vnd.pypi.simple.v1+json',
    })

    ---@param version string
    ---@param files table[]?
    ---@return boolean
    local function valid_version(version, files)
        if filter.final_release then
            -- https://packaging.python.org/en/latest/specifications/version-specifiers
            local parsed_version = vim.version.parse(version, { strict = true })
            if parsed_version == nil then
                return false
            end
        end
        if filter.yanked and files ~= nil then
            -- Based on observations of API responses, unsure if this is the correct approach
            -- Calling description API for every version seems too expensive
            local version_filename = string.format('%s-%s.tar.gz', name, version)
            for _, file in ipairs(files) do
                if file.filename == version_filename and file.yanked then
                    return false
                end
            end
        end
        return true
    end

    ---@return ModuleVersions
    local function parse_versions()
        if result == nil or result.versions == nil then
            return M.FAILED
        else
            local versions = {}
            for _, version in ipairs(result.versions) do
                if valid_version(version, result.files) then
                    table.insert(versions, version)
                end
            end
            return { status = M.ModuleStatus.VALID, values = versions }
        end
    end

    local versions = parse_versions()
    cache.versions[name] = versions
    return versions
end

---@param name string
---@param version? string
---@return ModuleDescription
function M.get_description(name, version)
    local cached_description = cache.descriptions[name]
    if cached_description then
        return cached_description
    end

    -- curl --location \
    --   -A 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)' \
    --   https://pypi.org/pypi/{module_name}/{version?}/json
    ---@return string
    local function get_path()
        if version then
            return string.format('pypi/%s/%s/json', name:lower(), version)
        else
            return string.format('pypi/%s/json', name:lower())
        end
    end
    local result = call_pypi(get_path(), {})

    ---@return ModuleDescription
    local function parse_description()
        if result == nil or result.info.description == nil then
            return {}
        else
            return {
                content = vim.split(result.info.description, '\n'),
                content_type = result.info.description_content_type,
            }
        end
    end

    local description = parse_description()
    cache.descriptions[name] = description
    return description
end

return M
