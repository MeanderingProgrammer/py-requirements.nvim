local Package = require('py-requirements.lib.package')
local util = require('py-requirements.lib.util')

---@class py.reqs.parser.Requirements: py.reqs.parser.Language
local M = {}

---@private
M.lang = 'requirements'

---@param buf integer
---@return py.reqs.Package[]
function M.packages(buf)
    local ok, tree = pcall(vim.treesitter.get_parser, buf, M.lang)
    if not ok or not tree then
        return {}
    end
    local query = util.query(M.lang, '(requirement) @requirement')
    if not query then
        return {}
    end
    local result = {} ---@type py.reqs.Package[]
    local root = tree:parse()[1]:root()
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
    local ok, tree = pcall(vim.treesitter.get_string_parser, str, M.lang)
    if not ok or not tree then
        return nil
    end
    return M.parse(str, tree:parse()[1]:root())
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
