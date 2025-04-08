local curl = require('py-requirements.curl')
local state = require('py-requirements.state')

---@class py.reqs.dependency.Versions
---@field status py.reqs.dependency.Status
---@field values string[]

---@class py.reqs.dependency.Description
---@field content? string[]
---@field kind? string

---@class py.reqs.Cache
local cache = {
    ---@type table<string, py.reqs.dependency.Versions>
    versions = {},
    ---@type table<string, py.reqs.dependency.Description>
    descriptions = {},
}

---@class py.reqs.Pypi
local M = {}

---@enum py.reqs.dependency.Status
M.Status = {
    LOADING = 1,
    INVALID = 2,
    VALID = 3,
}

---@type py.reqs.dependency.Versions
M.INITIAL = { status = M.Status.LOADING, values = {} }

---@type py.reqs.dependency.Versions
M.FAILED = { status = M.Status.INVALID, values = {} }

---@param name string
---@return py.reqs.dependency.Versions
function M.get_versions(name)
    local cached_versions = cache.versions[name]
    if cached_versions then
        return cached_versions
    end

    ---@param index_url? string
    ---@return any?
    local function call_index(index_url)
        if index_url == nil then
            return nil
        end
        -- curl -isSL \
        --   -A 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)' \
        --   -H 'Accept: application/vnd.pypi.simple.v1+json' \
        --   https://pypi.org/simple/{name}/
        return M.call_pypi(index_url .. name:lower() .. '/', {
            Accept = 'application/vnd.pypi.simple.v1+json',
        })
    end

    local result = call_index(state.config.index_url)
    if result == nil then
        result = call_index(state.config.extra_index_url)
    end

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
            local filename = string.format('%s-%s.tar.gz', name, version)
            for _, file in ipairs(files) do
                if file.filename == filename and file.yanked then
                    return false
                end
            end
        end
        return true
    end

    ---@return py.reqs.dependency.Versions
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
            return { status = M.Status.VALID, values = versions }
        end
    end

    local versions = parse_versions()
    cache.versions[name] = versions
    return versions
end

---@param name string
---@param version? string
---@return py.reqs.dependency.Description
function M.get_description(name, version)
    local cached_description = cache.descriptions[name]
    if cached_description then
        return cached_description
    end

    ---@return string
    local function get_path()
        if version ~= nil then
            return string.format('pypi/%s/%s/json', name:lower(), version)
        else
            return string.format('pypi/%s/json', name:lower())
        end
    end

    -- curl -isSL \
    --   -A 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)' \
    --   https://pypi.org/pypi/{dependency_name}/{version?}/json
    local result = M.call_pypi('https://pypi.org/' .. get_path())

    ---@return py.reqs.dependency.Description
    local function parse_description()
        if result == nil or result.info.description == nil then
            return {}
        else
            return {
                content = vim.split(result.info.description, '\n'),
                kind = result.info.description_content_type,
            }
        end
    end

    local description = parse_description()
    cache.descriptions[name] = description
    return description
end

---@private
---@param endpoint string
---@param request_headers? table<string,string>
---@return any?
function M.call_pypi(endpoint, request_headers)
    local repo = 'py-requirements.nvim'
    local user_agent = string.format(
        '%s (https://github.com/MeanderingProgrammer/%s)',
        repo,
        repo
    )
    local result = curl.get(endpoint, '-isSL', user_agent, request_headers)
    if result == nil or not vim.tbl_contains({ 200, 301 }, result.status) then
        return nil
    else
        return vim.json.decode(result.body)
    end
end

return M
