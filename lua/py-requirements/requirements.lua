---@param line string
---@return string
local function uncomment(line)
    -- Capture everything before a #
    -- If nothing mathces (no # exists) return the input
    return line:match('^([^#]*)#.*$') or line
end

---@param line string
---@return string
local function remove_whitespace(line)
    local result, _ = line:gsub('%s+', '')
    return result
end

---@enum JobKind
local DependencyKind = {
    EQUAL = 1,
}

---@param line string
---@return string|nil
---@return string|nil
local function equal_dependency(line)
    local name, version = line:match('^(.*)==(.*)$')
    return name, version
end

---@param line_number integer
---@param line string
local function parse_module(line_number, line)
    local name, version = equal_dependency(line)
    if name and version then
        return {
            line_number = line_number,
            name = name,
            version = version,
            kind = DependencyKind.EQUAL,
        }
    end
end

local M = {}

---@param buf integer
function M.parse_modules(buf)
    local modules = {}

    -- Reference: https://pip.pypa.io/en/stable/reference/requirements-file-format/
    -- Supports ignoring comments and equality versions
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i, line in ipairs(lines) do
        line = uncomment(line)
        line = remove_whitespace(line)
        if line:len() > 0 then
            local module = parse_module(i, line)
            if module then
                table.insert(modules, module)
            end
        end
    end

    return modules
end

return M
