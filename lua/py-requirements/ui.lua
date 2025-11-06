local state = require('py-requirements.state')

---@class py.reqs.DiagnosticInfo
---@field message string
---@field severity vim.diagnostic.Severity

---@class py.reqs.Ui
local M = {}

---@type integer
M.ns = vim.api.nvim_create_namespace('py-requirements.nvim')

---@param buf integer
---@param packages py.reqs.Package[]
---@param max_len integer
function M.display(buf, packages, max_len)
    local diagnostics = {} ---@type vim.Diagnostic[]
    for _, package in ipairs(packages) do
        local info = package:info()
        diagnostics[#diagnostics + 1] = {
            source = 'py-requirements',
            col = 0,
            lnum = package.row,
            severity = info.severity,
            message = info.message,
        }
    end

    vim.diagnostic.set(M.ns, buf, diagnostics, {
        virtual_text = {
            prefix = M.prefix,
            virt_text_win_col = max_len + state.config.diagnostic_opts.padding,
            spacing = 0,
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
---@param package py.reqs.Package
function M.upgrade(buf, package)
    local version = package.version
    local latest = package:latest()
    if version and latest then
        local row = package.row
        local start_col, end_col = version.col[1], version.col[2]
        local line = { latest }
        vim.api.nvim_buf_set_text(buf, row, start_col, row, end_col, line)
    end
end

---@param description py.reqs.pypi.Description
function M.show_description(description)
    local content = description.content
    if not content then
        return
    end

    local syntax_mapping = {
        ['text/x-rst'] = 'rst',
        ['text/markdown'] = 'markdown',
    }
    local syntax = syntax_mapping[description.type] or 'plaintext'

    local default = { focus_id = 'py-requirements.nvim' }
    local opts = vim.tbl_deep_extend('force', default, state.config.float_opts)

    local buf = vim.lsp.util.open_floating_preview(content, syntax, opts)
    if not vim.tbl_contains({ 'plaintext', 'markdown' }, syntax) then
        vim.bo[buf].filetype = syntax
    end
end

return M
