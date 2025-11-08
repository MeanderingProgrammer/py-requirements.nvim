local parser = require('py-requirements.parser')
local ui = require('py-requirements.lib.ui')
local util = require('py-requirements.lib.util')

---@class py.reqs.Actions
local M = {}

---@param all boolean
function M.upgrade(all)
    local buf = util.buffer()
    local row = not all and util.row() or nil
    M.run(buf, row, function(package)
        package:update()
        ui.upgrade(buf, package)
    end)
end

function M.show_description()
    local buf = util.buffer()
    local row = util.row()
    M.run(buf, row, function(package)
        ui.description(package)
    end)
end

---@private
---@param buf integer
---@param row? integer
---@param callback fun(package: py.reqs.Package)
function M.run(buf, row, callback)
    local packages = parser.packages(buf)
    for _, package in ipairs(packages) do
        if not row or package.row == row then
            vim.schedule(function()
                callback(package)
            end)
        end
    end
end

return M
