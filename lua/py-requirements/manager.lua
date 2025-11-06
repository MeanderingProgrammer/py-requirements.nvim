local parser = require('py-requirements.parser')
local state = require('py-requirements.state')
local ui = require('py-requirements.lib.ui')

---@type integer[]
local buffers = {}

---@class py.reqs.Manager
local M = {}

---@private
---@type integer
M.group = vim.api.nvim_create_augroup('PyRequirements', {})

function M.setup()
    vim.api.nvim_create_autocmd('FileType', {
        group = M.group,
        callback = function(args)
            M.attach(args.buf)
        end,
    })
end

---@param buf integer
---@return boolean
function M.active(buf)
    return vim.tbl_contains(buffers, buf)
end

---@private
---@param buf integer
function M.attach(buf)
    if M.active(buf) or not M.valid(buf) then
        return
    end
    buffers[#buffers + 1] = buf

    vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
        group = M.group,
        buffer = buf,
        callback = function()
            M.update(buf)
        end,
    })

    if state.config.enable_lsp then
        require('py-requirements.integrations.lsp').setup()
    end
    if state.config.enable_cmp then
        require('py-requirements.integrations.cmp').setup()
    end

    M.initialize(buf)
end

---@private
---@param buf integer
---@return boolean
function M.valid(buf)
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
    for _, pattern in ipairs(state.config.file_patterns) do
        local match = vim.regex(pattern):match_str(name)
        if match == 0 then
            return true
        end
    end
    return false
end

---@private
---@param buf integer
function M.initialize(buf)
    local packages = parser.packages(buf)
    ui.diagnostics(buf, packages)
    for _, package in ipairs(packages) do
        vim.schedule(function()
            package:update()
        end)
    end
    M.update(buf)
end

---@private
---@param buf integer
function M.update(buf)
    vim.schedule(function()
        local packages = parser.packages(buf)
        for _, package in ipairs(packages) do
            package:update()
        end
        ui.diagnostics(buf, packages)
    end)
end

return M
