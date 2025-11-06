local curl = require('py-requirements.lib.curl')
local state = require('py-requirements.state')
local util = require('py-requirements.lib.util')

---@class py.reqs.pypi.package.Response
---@field versions string[]
---@field files py.reqs.pypi.package.File[]

---@class py.reqs.pypi.package.File
---@field filename string
---@field yanked? boolean|string

---@class py.reqs.pypi.Versions
---@field values? string[]

---@class py.reqs.pypi.project.Response
---@field info py.reqs.pypi.project.Info

---@class py.reqs.pypi.project.Info
---@field description string
---@field description_content_type string

---@class py.reqs.pypi.Description
---@field lines? string[]
---@field syntax? string

---@class py.reqs.pypi.Cache
local cache = {
    ---@type table<string, py.reqs.pypi.Versions>
    versions = {},
    ---@type table<string, py.reqs.pypi.Description>
    descriptions = {},
}

---@class py.reqs.Pypi
local M = {}

---@param name string
---@return py.reqs.pypi.Versions
function M.get_versions(name)
    local result = cache.versions[name]
    if result then
        return result
    end

    ---@param index? string
    ---@return py.reqs.pypi.package.Response?
    local function call_index(index)
        if not index then
            return nil
        end
        return curl.get(('%s%s/'):format(index, name:lower()), {
            Accept = 'application/vnd.pypi.simple.v1+json',
        })
    end

    local response = call_index(state.config.index_url)
        or call_index(state.config.extra_index_url)

    if not response then
        result = {}
    else
        local values = {} ---@type string[]
        for _, version in ipairs(response.versions) do
            local valid = true
            if state.config.filter.final_release then
                -- https://packaging.python.org/en/latest/specifications/version-specifiers
                if not vim.version.parse(version, { strict = true }) then
                    valid = false
                end
            end
            if state.config.filter.yanked then
                -- Based on observations of API responses, unsure if this is the correct approach
                -- Calling description API for every version seems too expensive
                local filename = ('%s-%s.tar.gz'):format(name, version)
                for _, file in ipairs(response.files) do
                    if file.filename == filename and file.yanked then
                        valid = false
                    end
                end
            end
            if valid then
                values[#values + 1] = version
            end
        end

        -- If there are no versions left after filtering fallback to all
        if #values == 0 then
            values = response.versions
        end

        result = { values = values }
    end

    cache.versions[name] = result
    return result
end

---@param name string
---@param version? string
---@return py.reqs.pypi.Description
function M.get_description(name, version)
    local result = cache.descriptions[name]
    if result then
        return result
    end

    local endpoint = ('https://pypi.org/pypi/%s'):format(name:lower())
    if version then
        endpoint = ('%s/%s'):format(endpoint, version)
    end
    endpoint = ('%s/json'):format(endpoint)

    local response = curl.get(endpoint) ---@type py.reqs.pypi.project.Response?
    if not response then
        result = {}
    else
        local info = response.info
        local syntax = {
            ['text/x-rst'] = 'rst',
            ['text/markdown'] = 'markdown',
        }
        result = {
            lines = util.split(info.description, '\n'),
            syntax = syntax[info.description_content_type],
        }
    end

    cache.descriptions[name] = result
    return result
end

return M
