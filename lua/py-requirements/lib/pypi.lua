local Version = require('py-requirements.lib.version')
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
---@param callback fun(versions: py.reqs.pypi.Versions)
function M.get_versions(name, callback)
    local cached = cache.versions[name]
    if cached then
        callback(cached)
        return
    end

    ---@param index? string
    ---@param done fun(out?: py.reqs.pypi.package.Response)
    local function call(index, done)
        if not index then
            done(nil)
        else
            curl.get(
                ('%s%s/'):format(index, name:lower()),
                { Accept = 'application/vnd.pypi.simple.v1+json' },
                done
            )
        end
    end

    call(state.config.index_url, function(out1)
        if out1 then
            local result = M.parse_versions(name, out1)
            cache.versions[name] = result
            callback(result)
        else
            call(state.config.extra_index_url, function(out2)
                local result = out2 and M.parse_versions(name, out2) or {}
                cache.versions[name] = result
                callback(result)
            end)
        end
    end)
end

---@private
---@param name string
---@param out py.reqs.pypi.package.Response
---@return py.reqs.pypi.Versions
function M.parse_versions(name, out)
    local values = {} ---@type string[]
    for _, version in ipairs(out.versions) do
        local valid = true
        if state.config.filter.final_release then
            if not Version.new(version):final() then
                valid = false
            end
        end
        if state.config.filter.yanked then
            -- Based on observations of API responses, unsure if this is the correct approach
            -- Calling description API for every version seems too expensive
            local filename = ('%s-%s.tar.gz'):format(name, version)
            for _, file in ipairs(out.files) do
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
        values = out.versions
    end

    ---@type py.reqs.pypi.Versions
    return { values = values }
end

---@param name string
---@param version? string
---@return py.reqs.pypi.Description
function M.get_description(name, version)
    local cached = cache.descriptions[name]
    if cached then
        return cached
    end

    local endpoint = ('https://pypi.org/pypi/%s'):format(name:lower())
    if version then
        endpoint = ('%s/%s'):format(endpoint, version)
    end
    endpoint = ('%s/json'):format(endpoint)

    local out = curl.get(endpoint) ---@type py.reqs.pypi.project.Response?

    local result = {} ---@type py.reqs.pypi.Description
    if out then
        result = M.parse_description(out)
    end

    cache.descriptions[name] = result
    return result
end

---@private
---@param out py.reqs.pypi.project.Response
---@return py.reqs.pypi.Description
function M.parse_description(out)
    local info = out.info
    local mapping = {
        ['text/x-rst'] = 'rst',
        ['text/markdown'] = 'markdown',
    }
    ---@type py.reqs.pypi.Description
    return {
        lines = util.split(info.description, '\n'),
        syntax = mapping[info.description_content_type],
    }
end

return M
