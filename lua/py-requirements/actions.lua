local parser = require('py-requirements.parser')
local ui = require('py-requirements.lib.ui')

---@class py.reqs.Actions
local M = {}

---@param buf integer
---@param row? integer
function M.upgrade(buf, row)
    M.run(buf, row, function(package)
        package:update()
        ui.upgrade(buf, package)
    end)
end

---@param buf integer
---@param row integer
function M.show_description(buf, row)
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
