local parser = require('py-requirements.parser')
local pypi = require('py-requirements.pypi')
local state = require('py-requirements.state')
local ui = require('py-requirements.ui')

---@type integer[]
local buffers = {}

---@class py.reqs.Manager
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

    M.completions()

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
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':t')
    for _, pattern in ipairs(state.config.file_patterns) do
        local match = vim.regex(pattern):match_str(name)
        if match ~= nil and match == 0 then
            return true
        end
    end
    return false
end

---@private
function M.completions()
    if state.config.enable_lsp then
        require('py-requirements.integrations.lsp').setup()
    end
    if state.config.enable_cmp then
        require('py-requirements.integrations.cmp').setup()
    end
end

---@private
---@param buf integer
function M.initialize(buf)
    local dependencies = parser.dependencies(buf)
    local max_len = parser.max_len(buf, dependencies)
    ui.display(buf, dependencies, max_len)
    for _, dependency in ipairs(dependencies) do
        vim.schedule(function()
            pypi.get_versions(dependency.name)
        end)
    end
    M.display(buf)
end

---@private
---@param buf integer
function M.display(buf)
    vim.schedule(function()
        local dependencies = parser.dependencies(buf)
        local max_len = parser.max_len(buf, dependencies)
        for _, dependency in ipairs(dependencies) do
            dependency.versions = pypi.get_versions(dependency.name)
        end
        ui.display(buf, dependencies, max_len)
    end)
end

return M
