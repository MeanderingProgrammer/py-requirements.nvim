local state = require('py-requirements.state')

---@class py.reqs.Ui
local M = {}

---@type integer
M.ns = vim.api.nvim_create_namespace('py-requirements.nvim')

---@param buf integer
---@param packages py.reqs.Package[]
function M.diagnostics(buf, packages)
    local diagnostics = {} ---@type vim.Diagnostic[]
    for _, package in ipairs(packages) do
        local message, severity = package:info()
        diagnostics[#diagnostics + 1] = {
            lnum = package.row,
            col = 0,
            severity = severity,
            message = message,
            source = 'py-requirements',
        }
    end

    local width = 0
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for _, package in ipairs(packages) do
        local line = lines[package.row + 1]
        width = math.max(width, #line)
    end

    vim.diagnostic.set(M.ns, buf, diagnostics, {
        virtual_text = {
            prefix = M.prefix,
            virt_text_win_col = width + state.config.diagnostic_opts.padding,
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
    local mapping = {
        [vim.diagnostic.severity.INFO] = ' ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.ERROR] = ' ',
    }
    return mapping[diagnostic.severity]
end

---@param buf integer
---@param package py.reqs.Package
function M.upgrade(buf, package)
    local row = package.row
    local spec = package:spec()
    local latest = package:latest()
    if spec and latest then
        local cols = spec.cols
        vim.api.nvim_buf_set_text(buf, row, cols[1], row, cols[2], { latest })
    end
end

---@param package py.reqs.Package
function M.description(package)
    local description = package:description()
    local lines = description.lines
    local syntax = description.syntax or 'plaintext'
    local opts = vim.tbl_deep_extend(
        'force',
        { focus_id = 'py-requirements.nvim' },
        state.config.float_opts
    )
    if not lines then
        return
    end
    local buf = vim.lsp.util.open_floating_preview(lines, syntax, opts)
    if not vim.tbl_contains({ 'plaintext', 'markdown' }, syntax) then
        vim.bo[buf].filetype = syntax
    end
end

return M
