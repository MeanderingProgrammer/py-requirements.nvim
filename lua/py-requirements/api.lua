local curl = require('py-requirements.curl')
local state = require('py-requirements.state')

---@class py.requirements.ModuleVersions
---@field status py.requirements.ModuleStatus
---@field values string[]

---@class py.requirements.ModuleDescription
---@field content? string[]
---@field content_type? string

---@class py.requirements.Cache
---@field versions table<string,py.requirements.ModuleVersions>
---@field descriptions table<string,py.requirements.ModuleDescription>

---@type py.requirements.Cache
local cache = {
    versions = {},
    descriptions = {},
}

---@class py.requirements.Api
local M = {}

---@enum py.requirements.ModuleStatus
M.ModuleStatus = {
    LOADING = 1,
    INVALID = 2,
    VALID = 3,
}

---@type py.requirements.ModuleVersions
M.INITIAL = { status = M.ModuleStatus.LOADING, values = {} }

---@type py.requirements.ModuleVersions
M.FAILED = { status = M.ModuleStatus.INVALID, values = {} }

---@param name string
---@return py.requirements.ModuleVersions
function M.get_versions(name)
    local cached_versions = cache.versions[name]
    if cached_versions then
        return cached_versions
    end

    -- curl -isSL \
    --   -A 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)' \
    --   -H 'Accept: application/vnd.pypi.simple.v1+json' \
    --   https://pypi.org/simple/{name}/
    local result = M.call_pypi(string.format('simple/%s/', name:lower()), {
        Accept = 'application/vnd.pypi.simple.v1+json',
    })

    ---@param version string
    ---@param files table[]?
    ---@return boolean
    local function valid_version(version, files)
        local filter = state.config.filter
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

    ---@return py.requirements.ModuleVersions
    local function parse_versions()
        if result == nil or result.versions == nil then
            return M.FAILED
        else
            local versions = vim.tbl_filter(function(version)
                return valid_version(version, result.files)
            end, result.versions)
            -- If there are no versions left after filtering fallback to all
            if #versions == 0 then
                versions = result.versions
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
---@return py.requirements.ModuleDescription
function M.get_description(name, version)
    local cached_description = cache.descriptions[name]
    if cached_description then
        return cached_description
    end

    -- curl -isSL \
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
    local result = M.call_pypi(get_path())

    ---@return py.requirements.ModuleDescription
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

---@private
---@param path string
---@param request_headers? table<string,string>
---@return any?
function M.call_pypi(path, request_headers)
    local endpoint = string.format('https://pypi.org/%s', path)
    local user_agent = 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)'
    local result = curl.get(endpoint, '-isSL', user_agent, request_headers)
    if result == nil or not vim.tbl_contains({ 200, 301 }, result.status) then
        return nil
    else
        return vim.json.decode(result.body)
    end
end

return M
