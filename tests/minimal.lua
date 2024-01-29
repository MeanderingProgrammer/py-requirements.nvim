---@param path_name string
---@param plugin_name string
local function source_plugin(path_name, plugin_name)
    local path = vim.fs.find(path_name, { path = vim.fn.stdpath('data') })
    vim.opt.rtp:prepend(unpack(path))
    vim.cmd.runtime('plugin/' .. plugin_name)
end

vim.opt.rtp:prepend('.')
source_plugin('plenary.nvim', 'plenary.vim')
source_plugin('nvim-treesitter', 'nvim-treesitter.lua')

local parsers = { 'requirements' }
vim.cmd.TSInstallSync({ bang = true, args = parsers })
