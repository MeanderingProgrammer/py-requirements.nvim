local parser = require('py-requirements.parser')
local pypi = require('py-requirements.pypi')
local state = require('py-requirements.state')
local ui = require('py-requirements.ui')

---@type integer[]
local buffers = {}

---@class py.requirements.Manager
local M = {}

---@private
---@type integer
M.group = vim.api.nvim_create_augroup('PyRequirements', { clear = true })

function M.setup()
    vim.api.nvim_create_autocmd('BufRead', {
        group = M.group,
        callback = function(args)
            M.attach(args.buf)
        end,
    })
end

---@private
---@param buf integer
function M.attach(buf)
    if M.active(buf) or not M.valid(buf) then
        return
    end
    table.insert(buffers, buf)

    vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
        group = M.group,
        buffer = buf,
        callback = function()
            M.display(buf)
        end,
    })

    M.initialize(buf)
end

---@param buf integer
---@return boolean
function M.active(buf)
    return vim.tbl_contains(buffers, buf)
end

---@private
---@param buf integer
---@return boolean
function M.valid(buf)
    local file_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
    for _, file_pattern in ipairs(state.config.file_patterns) do
        local match = vim.regex(file_pattern):match_str(file_name)
        if match ~= nil and match == 0 then
            return true
        end
    end
    return false
end

---@private
---@param buf integer
function M.initialize(buf)
    local modules = parser.modules(buf)
    local max_len = parser.max_len(buf, modules)
    ui.display(buf, modules, max_len)
    for _, module in ipairs(modules) do
        vim.schedule(function()
            pypi.get_versions(module.name)
        end)
    end
    M.display(buf)
end

---@private
---@param buf integer
function M.display(buf)
    vim.schedule(function()
        local modules = parser.modules(buf)
        local max_len = parser.max_len(buf, modules)
        for _, module in ipairs(modules) do
            module.versions = pypi.get_versions(module.name)
        end
        ui.display(buf, modules, max_len)
    end)
end

return M
