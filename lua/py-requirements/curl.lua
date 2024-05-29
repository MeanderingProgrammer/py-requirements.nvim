---@class py.requirements.CurlResponse
---@field status number
---@field body string

local M = {}

---@param endpoint string
---@param options string
---@param user_agent string
---@param request_headers? table<string,string>
---@return py.requirements.CurlResponse?
function M.get(endpoint, options, user_agent, request_headers)
    local command = { 'curl', options, '-A', user_agent }
    if request_headers ~= nil then
        table.insert(command, '-H')
        for key, value in pairs(request_headers) do
            table.insert(command, string.format('%s: %s', key, value))
        end
    end
    table.insert(command, endpoint)

    local result = vim.system(command, { text = true }):wait()
    local sections = vim.split(vim.trim(result.stdout), '\n\n', { plain = true, trimempty = true })
    -- Expect at least a single set of response headers and a body
    if #sections < 2 then
        return nil
    end

    local response_headers = vim.split(sections[1], '\n', { plain = true, trimempty = true })
    local status_header = vim.split(response_headers[1], ' ', { plain = true, trimempty = true })
    -- Status header includes HTTP version followed by response code
    if #status_header < 2 then
        return nil
    end

    local status = tonumber(status_header[2])
    if status == nil then
        return nil
    end

    ---@type py.requirements.CurlResponse
    return {
        status = status,
        body = sections[#sections],
    }
end

return M
