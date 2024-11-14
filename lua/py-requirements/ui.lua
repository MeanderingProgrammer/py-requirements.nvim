local pypi = require('py-requirements.pypi')
local state = require('py-requirements.state')

---@class py.reqs.DiagnosticInfo
---@field message string
---@field severity vim.diagnostic.Severity

---@class py.reqs.Ui
local M = {}

---@type integer
M.namespace = vim.api.nvim_create_namespace('py-requirements.nvim')

---@param buf integer
---@param dependencies py.reqs.Dependency[]
---@param max_len integer
function M.display(buf, dependencies, max_len)
    local diagnostics = vim.iter(dependencies)
        :map(function(dependency)
            local info = M.diagnostic_info(dependency)
            ---@type vim.Diagnostic
            return {
                source = 'py-requirements',
                col = 0,
                lnum = dependency.line_number,
                severity = info.severity,
                message = info.message,
            }
        end)
        :totable()

    vim.diagnostic.set(M.namespace, buf, diagnostics, {
        virtual_text = {
            prefix = M.prefix,
            virt_text_win_col = max_len + state.config.diagnostic_opts.padding,
            spacing = 0,
        },
    })
end

---@private
---@param dependency py.reqs.Dependency
---@return py.reqs.DiagnosticInfo
function M.diagnostic_info(dependency)
    local version = dependency.version
    local versions = dependency.versions
    if versions.status == pypi.Status.LOADING then
        ---@type py.reqs.DiagnosticInfo
        return {
            message = 'Loading',
            severity = vim.diagnostic.severity.INFO,
        }
    elseif versions.status == pypi.Status.INVALID then
        ---@type py.reqs.DiagnosticInfo
        return {
            message = 'Error fetching library',
            severity = vim.diagnostic.severity.ERROR,
        }
    elseif versions.status == pypi.Status.VALID then
        if #versions.values == 0 then
            ---@type py.reqs.DiagnosticInfo
            return {
                message = 'No versions found',
                severity = vim.diagnostic.severity.ERROR,
            }
        elseif version ~= nil and not vim.tbl_contains(versions.values, version.value) then
            ---@type py.reqs.DiagnosticInfo
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
            ---@type py.reqs.DiagnosticInfo
            return {
                message = latest_version,
                severity = severity,
            }
        end
    else
        error(string.format('Unhandled library status: %d', versions.status))
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
---@param dependency py.reqs.Dependency
function M.upgrade(buf, dependency)
    local version = dependency.version
    local latest_version = dependency.versions.values[#dependency.versions.values]
    if version and latest_version then
        local row = dependency.line_number
        local line = { latest_version }
        vim.api.nvim_buf_set_text(buf, row, version.start_col, row, version.end_col, line)
    end
end

---@param description py.reqs.dependency.Description
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
