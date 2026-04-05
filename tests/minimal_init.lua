---@param name string
---@return string
local function get_path(name)
    local paths = vim.fs.find(name, { path = vim.fn.stdpath('data') })
    assert(#paths == 1, 'plugin must have one path')
    return paths[1]
end

-- source dependencies first
vim.opt.rtp:prepend(get_path('nvim-treesitter'))
vim.cmd.runtime('plugin/nvim-treesitter.lua')

-- source this plugin
vim.opt.rtp:prepend('.')

-- used for unit testing
vim.opt.rtp:prepend(get_path('plenary.nvim'))
vim.cmd.runtime('plugin/plenary.vim')

require('nvim-treesitter').install({ 'requirements', 'toml' }):wait()
