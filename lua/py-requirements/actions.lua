local parser = require('py-requirements.parser')
local ui = require('py-requirements.lib.ui')
local util = require('py-requirements.lib.util')

---@class py.reqs.Actions
local M = {}

---@param all boolean
function M.upgrade(all)
    local buf = util.buffer()
    local row = not all and util.row() or nil
    M.run(buf, row, function(pack)
        pack:update()
        ui.upgrade(buf, pack)
    end)
end

function M.show_description()
    local buf = util.buffer()
    local row = util.row()
    M.run(buf, row, function(pack)
        ui.description(pack)
    end)
end

---@private
---@param buf integer
---@param row? integer
---@param callback fun(pack: py.reqs.Pack)
function M.run(buf, row, callback)
    local packs = parser.buf(buf)
    for _, pack in ipairs(packs) do
        if not row or pack.row == row then
            vim.schedule(function()
                callback(pack)
            end)
        end
    end
end

return M
