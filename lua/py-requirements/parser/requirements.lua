local Pack = require('py-requirements.lib.pack')
local util = require('py-requirements.lib.util')

---@class py.reqs.parser.Requirements: py.reqs.parser.Language
local M = {}

---@private
M.lang = 'requirements'

---@param buf integer
---@return py.reqs.Pack[]
function M.buf(buf)
    local root = util.root(buf, M.lang)
    if not root then
        return {}
    end
    local query = util.query(M.lang, '(requirement) @pack')
    if not query then
        return {}
    end
    local result = {} ---@type py.reqs.Pack[]
    for _, node in query:iter_captures(root, buf) do
        local pack = M.parse(buf, node)
        if pack then
            result[#result + 1] = pack
        end
    end
    return result
end

---@param str string
---@return py.reqs.Pack?
function M.line(str)
    local root = util.root(str, M.lang)
    return root and M.parse(str, root)
end

---@private
---@param source integer|string
---@param root TSNode
---@return py.reqs.Pack?
function M.parse(source, root)
    -- stylua: ignore
    local query = util.query(M.lang, [[
        (requirement (package) @name)
        (version_spec (version_cmp) @cmp)
        (version_spec (version) @version)
    ]])
    if not query then
        return nil
    end
    local name = nil ---@type TSNode?
    local cmps = {} ---@type TSNode[]
    local versions = {} ---@type TSNode[]
    for id, node in query:iter_captures(root, source) do
        local capture = query.captures[id]
        if capture == 'name' then
            name = node
        elseif capture == 'cmp' then
            cmps[#cmps + 1] = node
        elseif capture == 'version' then
            versions[#versions + 1] = node
        end
    end
    if not name then
        return nil
    end
    return Pack.new(source, name, cmps, versions)
end

return M
