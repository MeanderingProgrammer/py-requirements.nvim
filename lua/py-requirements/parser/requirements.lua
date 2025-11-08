local Package = require('py-requirements.lib.package')
local util = require('py-requirements.lib.util')

---@class py.reqs.parser.Requirements: py.reqs.parser.Language
local M = {}

---@private
M.lang = 'requirements'

---@param buf integer
---@return py.reqs.Package[]
function M.packages(buf)
    local root = util.root(buf, M.lang)
    if not root then
        return {}
    end
    local query = util.query(M.lang, '(requirement) @package')
    if not query then
        return {}
    end
    local result = {} ---@type py.reqs.Package[]
    for _, node in query:iter_captures(root, buf) do
        local package = M.parse(buf, node)
        if package then
            result[#result + 1] = package
        end
    end
    return result
end

---@param str string
---@return py.reqs.Package?
function M.line(str)
    local root = util.root(str, M.lang)
    return root and M.parse(str, root)
end

---@private
---@param source integer|string
---@param root TSNode
---@return py.reqs.Package?
function M.parse(source, root)
    -- stylua: ignore
    local query = util.query(M.lang, [[
        (requirement (package) @name)
        (version_spec (version) @version)
    ]])
    if not query then
        return nil
    end
    local name = nil ---@type TSNode?
    local version = nil ---@type TSNode?
    for id, node in query:iter_captures(root, source) do
        local capture = query.captures[id]
        if capture == 'name' then
            name = node
        elseif capture == 'version' then
            version = node
        end
    end
    return Package.new(source, name, version)
end

return M
