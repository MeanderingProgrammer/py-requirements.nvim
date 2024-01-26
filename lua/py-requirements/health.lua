local py_requirments = require('py-requirements')

---@param name string
local function plugin_installed(name)
    local ok = pcall(require, name)
    if ok then
        vim.health.ok(name .. ' plugin installed')
    else
        vim.health.error(name .. ' plugin not found')
    end
end

---@param name string
local function parser_installed(name)
    local ok = pcall(vim.treesitter.query.parse, name, '')
    if ok then
        vim.health.ok(name .. ' parser installed')
    else
        vim.health.error(name .. ' parser not found')
    end
end

---@param name string
local function binary_installed(name)
    if vim.fn.has('win32') == 1 then
        name = name .. '.exe'
    end
    if vim.fn.executable(name) == 1 then
        vim.health.ok(name .. ' command installed')
    else
        vim.health.error(name .. ' command not found')
    end
end

local M = {}

function M.check()
    vim.health.start('Checking required plugins')
    plugin_installed('plenary')
    if py_requirments.get_config().enable_cmp then
        plugin_installed('cmp')
    end

    vim.health.start('Checking required treesitter parsers')
    parser_installed('requirements')

    vim.health.start('Checking external dependencies')
    binary_installed('curl')
end

return M
