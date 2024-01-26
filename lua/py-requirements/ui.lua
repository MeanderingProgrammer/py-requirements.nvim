local NAMESPACE = vim.api.nvim_create_namespace('py-requirements.nvim')

---@param module PythonModule
---@return Diagnostic
local function to_diagnostic(module)
    local severity = vim.diagnostic.severity.INFO
    local latest_version = module.versions[#module.versions]
    if latest_version then
        if latest_version ~= module.version then
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

return M
