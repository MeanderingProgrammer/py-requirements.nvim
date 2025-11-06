local util = require('py-requirements.lib.util')

local url = 'https://github.com/MeanderingProgrammer'
local repo = 'py-requirements.nvim'

---@class py.reqs.Curl
local M = {}

---@param endpoint string
---@param headers? table<string, string>
---@return any
function M.get(endpoint, headers)
    local cmd = { 'curl', '-isSL' } ---@type string[]
    cmd[#cmd + 1] = '-A'
    cmd[#cmd + 1] = ('%s (%s/%s)'):format(repo, url, repo)
    for key, value in pairs(headers or {}) do
        cmd[#cmd + 1] = '-H'
        cmd[#cmd + 1] = ('%s: %s'):format(key, value)
    end
    cmd[#cmd + 1] = endpoint

    local response = vim.system(cmd, { text = true }):wait()
    if response.code ~= 0 then
        return nil
    end

    -- must contain a set of headers and a body
    local sections = util.split(vim.trim(response.stdout), '\n\n')
    if #sections < 2 then
        return nil
    end

    -- first header is HTTP version followed by response code: HTTP/2 200
    local header = util.split(sections[1], '\n')[1]
    local status = tonumber(util.split(header, ' ')[2])
    if not status or not vim.tbl_contains({ 200, 301 }, status) then
        return nil
    end

    local ok, result = pcall(vim.json.decode, sections[#sections])
    return ok and result or nil
end

return M
