local api = require('py-requirements.api')

local NAMESPACE = vim.api.nvim_create_namespace('py-requirements.nvim')

---@param module PythonModule
---@return Diagnostic
local function to_diagnostic(module)
    local message = nil
    local severity = nil
    if module.versions.status == api.ModuleStatus.LOADING then
        severity = vim.diagnostic.severity.INFO
        message = ' Loading'
    elseif module.versions.status == api.ModuleStatus.INVALID then
        severity = vim.diagnostic.severity.ERROR
        message = ' Error fetching module'
    elseif module.versions.status == api.ModuleStatus.VALID then
        local latest_version = module.versions.values[#module.versions.values]
        if latest_version == nil then
            severity = vim.diagnostic.severity.WARN
            message = ' No versions'
        elseif module.version ~= nil and latest_version ~= module.version.value then
            severity = vim.diagnostic.severity.WARN
            message = ' ' .. latest_version
        else
            severity = vim.diagnostic.severity.INFO
            message = ' ' .. latest_version
        end
    end

    ---@type Diagnostic
    return {
        lnum = module.line_number,
        col = 0,
        severity = severity,
        message = message,
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
    local latest_version = module.versions.values[#module.versions.values]
    if version and latest_version then
        local row = module.line_number
        local line = { latest_version }
        vim.api.nvim_buf_set_text(buf, row, version.start_col, row, version.end_col, line)
    end
end

return M
