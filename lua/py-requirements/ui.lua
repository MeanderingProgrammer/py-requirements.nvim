local api = require('py-requirements.api')
local state = require('py-requirements.state')

---@class DiagnosticInfo
---@field message string
---@field severity vim.diagnostic.Severity

---@param module PythonModule
---@return DiagnosticInfo
local function diagnostic_info(module)
    local version = module.version
    local versions = module.versions
    if versions.status == api.ModuleStatus.LOADING then
        ---@type DiagnosticInfo
        return {
            message = 'Loading',
            severity = vim.diagnostic.severity.INFO,
        }
    elseif versions.status == api.ModuleStatus.INVALID then
        ---@type DiagnosticInfo
        return {
            message = 'Error fetching module',
            severity = vim.diagnostic.severity.ERROR,
        }
    elseif versions.status == api.ModuleStatus.VALID then
        if #versions.values == 0 then
            ---@type DiagnosticInfo
            return {
                message = 'No versions found',
                severity = vim.diagnostic.severity.ERROR,
            }
        elseif version ~= nil and not vim.tbl_contains(versions.values, version.value) then
            ---@type DiagnosticInfo
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
            ---@type DiagnosticInfo
            return {
                message = latest_version,
                severity = severity,
            }
        end
    else
        error(string.format('Unhandled module status: %d', versions.status))
    end
end

local M = {}

M.NAMESPACE = vim.api.nvim_create_namespace('py-requirements.nvim')

---@param buf integer
---@param modules PythonModule[]
---@param max_len integer
function M.display(buf, modules, max_len)
    local diagnostics = vim.iter(modules)
        :map(function(module)
            local info = diagnostic_info(module)
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

    vim.diagnostic.set(M.NAMESPACE, buf, diagnostics, {
        virtual_text = {
            prefix = M.prefix,
            virt_text_win_col = max_len,
        },
    })
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

---@param description ModuleDescription
function M.show_description(description)
    if description.content == nil then
        return
    end
    local syntax = 'plaintext'
    if description.content_type == 'text/x-rst' then
        syntax = 'rst'
    elseif description.content_type == 'text/markdown' then
        syntax = 'markdown'
    end
    local opts = vim.tbl_deep_extend('force', { focus_id = 'py-requirements.nvim' }, state.config.float_opts)
    local buf, _ = vim.lsp.util.open_floating_preview(description.content, syntax, opts)
    if not vim.tbl_contains({ 'plaintext', 'markdown' }, syntax) then
        vim.bo[buf].filetype = syntax
    end
end

return M
