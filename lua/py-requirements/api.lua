local curl = require('plenary.curl')

---@return string[]
local function parse_versions(result)
    if result == nil or (result.status ~= 200 and result.status ~= 301) then
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
---@return string[]
function M.get_versions(name)
    local cached_versions = cache.versions[name]
    if cached_versions then
        return cached_versions
    end
    -- curl \
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
    local versions = parse_versions(result)
    cache.versions[name] = versions
    return versions
end

return M
