local curl = require('plenary.curl')

---@return string[]
local function parse_versions(result)
    if result == nil or result.status ~= 200 then
        return {}
    end
    local json = vim.json.decode(result.body)
    if json == nil or json.versions == nil then
        return {}
    end
    return json.versions
end

---@class Cache
---@field versions table<string,string[]>

---@type Cache
local cache = {
    versions = {},
}

local M = {}

---@param name string
---@param callback fun(versions: string[])
function M.get_versions(name, callback)
    local cached_versions = cache.versions[name]
    if cached_versions then
        callback(cached_versions)
        return
    end
    -- curl \
    --   -H 'Accept: application/vnd.pypi.simple.v1+json' \
    --   -A 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)' \
    --   https://pypi.org/simple/{name}/
    curl.get(string.format('https://pypi.org/simple/%s/', name:lower()), {
        headers = {
            ['Accept'] = 'application/vnd.pypi.simple.v1+json',
            ['User-Agent'] = 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)',
        },
        callback = function(result)
            local versions = parse_versions(result)
            cache.versions[name] = versions
            callback(versions)
        end,
    })
end

return M
