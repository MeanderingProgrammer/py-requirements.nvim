local api = require('py-requirements.api')
local requirements = require('py-requirements.requirements')

local M = {}

---@param buf integer
---@param module PythonModule
local function update_version(buf, module)
    if not (module.version.start_col and module.version.end_col) then
        return
    end

    local versions = api.get_versions(module.name)

    vim.api.nvim_buf_set_text(
        buf,
        module.line_number,
        module.version.start_col,
        module.line_number,
        module.version.end_col,
        { versions[#versions] }
    )
end

---@param buf integer
---@param start_line integer
---@param end_line integer
function M.update(buf, start_line, end_line)
    local modules = requirements.parse_modules(buf, start_line, end_line)

    for _, module in ipairs(modules) do
        update_version(buf, module)
    end
end

return M
