local Package = require('py-requirements.lib.package')
local ts = require('py-requirements.lib.ts')

---@class py.reqs.parser.Requirements
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
    local query = ts.parse(M.lang, '(requirement) @requirement')
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

---@param line string
---@return py.reqs.Package?
function M.line(line)
    -- adding a 0 at the end as if we started typing a version number
    line = line .. '0'
    local ok, tree = pcall(vim.treesitter.get_string_parser, line, M.lang)
    if not ok or not tree then
        return nil
    end
    return M.parse(line, tree:parse()[1]:root())
end

---@private
---@param source (integer|string)
---@param root TSNode
---@return py.reqs.Package?
function M.parse(source, root)
    -- stylua: ignore
    local query = ts.parse(M.lang, [[
        (requirement (package) @name)
        (version_spec (version_cmp) @cmp)
        (version_spec (version) @version)
    ]])
    if not query then
        return nil
    end
    local name = nil ---@type string?
    local comparison = nil ---@type string?
    local version = nil ---@type py.reqs.package.Node?
    for id, node in query:iter_captures(root, source) do
        local capture = query.captures[id]
        local value = vim.treesitter.get_node_text(node, source)
        if capture == 'name' then
            name = value
        elseif capture == 'cmp' then
            comparison = value
        elseif capture == 'version' then
            local _, start_col, _, end_col = node:range()
            version = {
                value = value,
                col = { start_col, end_col },
            }
        end
    end
    return Package.new(root:start(), name, comparison, version)
end

return M
