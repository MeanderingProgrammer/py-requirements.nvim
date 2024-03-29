local api = require('py-requirements.api')
local state = require('py-requirements.state')

---@class DiagnosticInfo
---@field message string
---@field severity DiagnosticSeverity
---@field highlight string

---@param module PythonModule
---@return DiagnosticInfo|nil
local function to_diagnostic_info(module)
    if module.versions.status == api.ModuleStatus.LOADING then
        ---@type DiagnosticInfo
        return {
            message = ' Loading',
            severity = vim.diagnostic.severity.INFO,
            highlight = 'DiagnosticVirtualTextInfo',
        }
    elseif module.versions.status == api.ModuleStatus.INVALID then
        ---@type DiagnosticInfo
        return {
            message = ' Error fetching module',
            severity = vim.diagnostic.severity.ERROR,
            highlight = 'DiagnosticVirtualTextError',
        }
    elseif module.versions.status == api.ModuleStatus.VALID then
        local latest_version = module.versions.values[#module.versions.values]
        if latest_version == nil then
            ---@type DiagnosticInfo
            return {
                message = ' No versions',
                severity = vim.diagnostic.severity.ERROR,
                highlight = 'DiagnosticVirtualTextError',
            }
        elseif module.version ~= nil and not vim.tbl_contains(module.versions.values, module.version.value) then
            ---@type DiagnosticInfo
            return {
                message = ' Invalid version',
                severity = vim.diagnostic.severity.ERROR,
                highlight = 'DiagnosticVirtualTextError',
            }
        elseif module.version ~= nil and latest_version ~= module.version.value then
            ---@type DiagnosticInfo
            return {
                message = ' ' .. latest_version,
                severity = vim.diagnostic.severity.WARN,
                highlight = 'DiagnosticVirtualTextWarn',
            }
        else
            ---@type DiagnosticInfo
            return {
                message = ' ' .. latest_version,
                severity = vim.diagnostic.severity.INFO,
                highlight = 'DiagnosticVirtualTextInfo',
            }
        end
    else
        -- Should never get here, need a better way to handle this case
        return nil
    end
end

local M = {}

M.DIAGNOSTIC_NAMESPACE = vim.api.nvim_create_namespace('py-requirements.nvim.diagnostic')
M.TEXT_NAMESPACE = vim.api.nvim_create_namespace('py-requirements.nvim.text')

---@param buf integer
---@param modules PythonModule[]
---@param max_len integer
function M.display(buf, modules, max_len)
    vim.api.nvim_buf_clear_namespace(buf, M.TEXT_NAMESPACE, 0, -1)

    local diagnostics = {}
    for _, module in ipairs(modules) do
        local diagnostic_info = to_diagnostic_info(module)
        if diagnostic_info then
            ---@type Diagnostic
            local diagnostic = {
                lnum = module.line_number,
                col = 0,
                severity = diagnostic_info.severity,
                message = diagnostic_info.message,
                source = 'py-requirements',
            }
            table.insert(diagnostics, diagnostic)

            vim.api.nvim_buf_set_extmark(buf, M.TEXT_NAMESPACE, module.line_number, -1, {
                virt_text = { { diagnostic_info.message, diagnostic_info.highlight } },
                virt_text_win_col = max_len + 5,
            })
        end
    end

    vim.diagnostic.set(M.DIAGNOSTIC_NAMESPACE, buf, diagnostics, { virtual_text = false })
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
