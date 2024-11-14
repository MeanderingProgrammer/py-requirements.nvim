local state = require('py-requirements.state')

---@class py.reqs.Health
local M = {}

function M.check()
    vim.health.start('Checking Neovim version')
    M.neovim_version('0.10')

    vim.health.start('Checking required plugins')
    if state.config.enable_cmp then
        M.plugin_installed('cmp')
    end

    vim.health.start('Checking required treesitter parsers')
    M.parser_installed('requirements')

    vim.health.start('Checking external dependencies')
    M.binary_installed('curl')
end

---@private
---@param min_version string
function M.neovim_version(min_version)
    if vim.fn.has('nvim-' .. min_version) == 1 then
        vim.health.ok('Version is >= ' .. min_version)
    else
        vim.health.error('Version is not >= ' .. min_version)
    end
end

---@private
---@param name string
function M.plugin_installed(name)
    local ok = pcall(require, name)
    if ok then
        vim.health.ok(name .. ' plugin installed')
    else
        vim.health.error(name .. ' plugin not found')
    end
end

---@private
---@param name string
function M.parser_installed(name)
    local ok = pcall(vim.treesitter.query.parse, name, '')
    if ok then
        vim.health.ok(name .. ' parser installed')
    else
        vim.health.error(name .. ' parser not found')
    end
end

---@private
---@param name string
function M.binary_installed(name)
    if vim.fn.has('win32') == 1 then
        name = name .. '.exe'
    end
    if vim.fn.executable(name) == 1 then
        vim.health.ok(name .. ' command installed')
    else
        vim.health.error(name .. ' command not found')
    end
end

return M
