---@class py.reqs.curl.Response
---@field status number
---@field body string

---@class py.reqs.Curl
local M = {}

---@param endpoint string
---@param options string
---@param user_agent string
---@param request_headers? table<string,string>
---@return py.reqs.curl.Response?
function M.get(endpoint, options, user_agent, request_headers)
    local command = { 'curl', options, '-A', user_agent }
    if request_headers ~= nil then
        command[#command + 1] = '-H'
        for key, value in pairs(request_headers) do
            command[#command + 1] = string.format('%s: %s', key, value)
        end
    end
    command[#command + 1] = endpoint

    local result = vim.system(command, { text = true }):wait()
    local sections = M.split(vim.trim(result.stdout), '\n\n')
    -- Expect at least a single set of response headers and a body
    if #sections < 2 then
        return nil
    end

    local response_headers = M.split(sections[1], '\n')
    local status_header = M.split(response_headers[1], ' ')
    -- Status header includes HTTP version followed by response code
    if #status_header < 2 then
        return nil
    end

    local status = tonumber(status_header[2])
    if status == nil then
        return nil
    end

    ---@type py.reqs.curl.Response?
    return {
        status = status,
        body = sections[#sections],
    }
end

---@private
---@param s string
---@param sep string
---@return string[]
function M.split(s, sep)
    return vim.split(s, sep, { plain = true, trimempty = true })
end

return M
