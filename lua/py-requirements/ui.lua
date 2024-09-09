local pypi = require('py-requirements.pypi')
local state = require('py-requirements.state')

---@class py.requirements.DiagnosticInfo
---@field message string
---@field severity vim.diagnostic.Severity

---@class py.requirements.Ui
local M = {}

---@type integer
M.namespace = vim.api.nvim_create_namespace('py-requirements.nvim')

---@param buf integer
---@param modules py.requirements.PythonModule[]
---@param max_len integer
function M.display(buf, modules, max_len)
    local diagnostics = vim.iter(modules)
        :map(function(module)
            local info = M.diagnostic_info(module)
            ---@type vim.Diagnostic
            return {
                source = 'py-requirements',
                col = 0,
                lnum = module.line_number,
                severity = info.severity,
                message = info.message,
            }
        end)
        :totable()

    vim.diagnostic.set(M.namespace, buf, diagnostics, {
        virtual_text = {
            prefix = M.prefix,
            virt_text_win_col = max_len,
        },
    })
end

---@private
---@param module py.requirements.PythonModule
---@return py.requirements.DiagnosticInfo
function M.diagnostic_info(module)
    local version = module.version
    local versions = module.versions
    if versions.status == pypi.ModuleStatus.LOADING then
        ---@type py.requirements.DiagnosticInfo
        return {
            message = 'Loading',
            severity = vim.diagnostic.severity.INFO,
        }
    elseif versions.status == pypi.ModuleStatus.INVALID then
        ---@type py.requirements.DiagnosticInfo
        return {
            message = 'Error fetching module',
            severity = vim.diagnostic.severity.ERROR,
        }
    elseif versions.status == pypi.ModuleStatus.VALID then
        if #versions.values == 0 then
            ---@type py.requirements.DiagnosticInfo
            return {
                message = 'No versions found',
                severity = vim.diagnostic.severity.ERROR,
            }
        elseif version ~= nil and not vim.tbl_contains(versions.values, version.value) then
            ---@type py.requirements.DiagnosticInfo
            return {
                message = 'Invalid version',
                severity = vim.diagnostic.severity.ERROR,
            }
        else
            local latest_version = versions.values[#versions.values]
            local severity = vim.diagnostic.severity.INFO
            if version ~= nil and latest_version ~= version.value then
                severity = vim.diagnostic.severity.WARN
            end
            ---@type py.requirements.DiagnosticInfo
            return {
                message = latest_version,
                severity = severity,
            }
        end
    else
        error(string.format('Unhandled module status: %d', versions.status))
    end
end

---@param diagnostic vim.Diagnostic
---@return string
function M.prefix(diagnostic)
    if diagnostic.message == 'Loading' then
        return ' '
    end
    local severity_mapping = {
        [vim.diagnostic.severity.ERROR] = ' ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.INFO] = ' ',
    }
    return severity_mapping[diagnostic.severity]
end

---@param buf integer
---@param module py.requirements.PythonModule
function M.upgrade(buf, module)
    local version = module.version
    local latest_version = module.versions.values[#module.versions.values]
    if version and latest_version then
        local row = module.line_number
        local line = { latest_version }
        vim.api.nvim_buf_set_text(buf, row, version.start_col, row, version.end_col, line)
    end
end

---@param description py.requirements.ModuleDescription
function M.show_description(description)
    if description.content == nil then
        return
    end

    local syntax_mapping = {
        ['text/x-rst'] = 'rst',
        ['text/markdown'] = 'markdown',
    }
    local syntax = syntax_mapping[description.type] or 'plaintext'

    local default_opts = { focus_id = 'py-requirements.nvim' }
    local opts = vim.tbl_deep_extend('force', default_opts, state.config.float_opts)

    local buf, _ = vim.lsp.util.open_floating_preview(description.content, syntax, opts)
    if not vim.tbl_contains({ 'plaintext', 'markdown' }, syntax) then
        vim.bo[buf].filetype = syntax
    end
end

return M
