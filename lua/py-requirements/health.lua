---@param name string
local function plugin_installed(name)
    local ok = pcall(require, name)
    if ok then
        vim.health.ok(name .. ' installed')
    else
        vim.health.error(name .. ' not found')
    end
end

---@param name string
local function binary_installed(name)
    if vim.fn.has('win32') == 1 then
        name = name .. '.exe'
    end
    if vim.fn.executable(name) == 1 then
        vim.health.ok(name .. ' installed')
    else
        vim.health.error(name .. ' not found')
    end
end

local M = {}

function M.check()
    vim.health.start('Checking required plugins')
    plugin_installed('plenary')

    vim.health.start('Checking external dependencies')
    binary_installed('curl')
end

return M
