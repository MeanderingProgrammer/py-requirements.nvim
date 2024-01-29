local NAMESPACE = vim.api.nvim_create_namespace('py-requirements.nvim')

---@param module PythonModule
---@return Diagnostic
local function to_diagnostic(module)
    local severity = vim.diagnostic.severity.INFO
    local latest_version = module.versions[#module.versions]
    if latest_version then
        if module.version == nil or latest_version ~= module.version.value then
            severity = vim.diagnostic.severity.WARN
        end
        latest_version = ' ' .. latest_version
    end
    ---@type Diagnostic
    return {
        lnum = module.line_number,
        col = 0,
        severity = severity,
        message = latest_version or ' Loading',
        source = 'py-requirements',
    }
end

local M = {}

---@param buf integer
---@param modules PythonModule[]
function M.display(buf, modules)
    local diagnostics = {}
    for _, module in ipairs(modules) do
        local diagnostic = to_diagnostic(module)
        table.insert(diagnostics, diagnostic)
    end
    vim.diagnostic.set(NAMESPACE, buf, diagnostics)
end

---@param buf integer
---@param module PythonModule
function M.upgrade(buf, module)
    local version = module.version
    local latest_version = module.versions[#module.versions]
    if version and latest_version then
        local row = module.line_number
        local line = { latest_version }
        vim.api.nvim_buf_set_text(buf, row, version.start_col, row, version.end_col, line)
    end
end

return M
