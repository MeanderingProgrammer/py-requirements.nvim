local NAMESPACE = vim.api.nvim_create_namespace('py-requirements.nvim')

---@param module PythonModule
---@return Diagnostic|nil
local function to_diagnostic(module)
    if #module.versions == 0 then
        return nil
    end
    local latest_version = module.versions[#module.versions]
    local severity = vim.diagnostic.severity.INFO
    if module.version ~= latest_version then
        severity = vim.diagnostic.severity.WARN
    end
    ---@type Diagnostic
    return {
        lnum = module.line_number,
        col = 0,
        severity = severity,
        message = latest_version,
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
        if diagnostic then
            table.insert(diagnostics, diagnostic)
        end
    end
    vim.diagnostic.set(NAMESPACE, buf, diagnostics)
end

return M
