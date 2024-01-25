local curl = require('plenary.curl')

local M = {}

---@param name string
function M.get_versions(name)
    -- curl \
    --   -H 'Accept: application/vnd.pypi.simple.v1+json' \
    --   -A 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)' \
    --   https://pypi.org/simple/{name}/
    local headers = {
        ['Accept'] = 'application/vnd.pypi.simple.v1+json',
        ['User-Agent'] = 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)',
    }
    local url = string.format('https://pypi.org/simple/%s/', name)
    local result = curl.get(url, { headers = headers })
    if result == nil or result.status ~= 200 then
        return {}
    end
    local json = vim.json.decode(result.body)
    if json == nil or json.versions == nil then
        return {}
    end
    return json.versions
end

return M
