local requirements = require('py-requirements.parser.requirements')
local util = require('py-requirements.lib.util')

---@class py.reqs.parser.Toml: py.reqs.parser.Language
local M = {}

---@private
M.lang = 'toml'

---@param buf integer
---@return py.reqs.Pack[]
function M.buf(buf)
    local root = util.root(buf, M.lang)
    if not root then
        return {}
    end
    -- stylua: ignore
    local query = util.query(M.lang, [[
        (table
            (bare_key) @name
            (pair (bare_key) @key (array (string) @pep))
            (#eq? @name "project")
            (#eq? @key "dependencies"))

        (table
            (bare_key) @name
            (pair (array (string) @pep))
            (#eq? @name "dependency-groups"))

        (table
            (dotted_key) @name
            (pair (array (string) @pep))
            (#eq? @name "project.optional-dependencies"))

        (table
            (dotted_key) @name
            (pair) @poetry
            (#lua-match? @name "^tool.poetry.*.dependencies$"))
    ]])
    if not query then
        return {}
    end
    local result = {} ---@type py.reqs.Pack[]
    for id, node in query:iter_captures(root, buf) do
        local capture = query.captures[id]
        local pack = nil ---@type py.reqs.Pack?
        if capture == 'pep' then
            pack = M.parse_pep(buf, node)
        elseif capture == 'poetry' then
            pack = M.parse_poetry(buf, node)
        end
        if pack then
            result[#result + 1] = pack
        end
    end
    return result
end

---@private
---@param buf integer
---@param root TSNode
---@return py.reqs.Pack?
function M.parse_pep(buf, root)
    -- "requests==2.0.0"
    local text = vim.treesitter.get_node_text(root, buf)
    text = text:sub(2, -2) .. '\n'
    local pack = requirements.line(text)
    if pack then
        local row, col = root:range()
        pack:shift(row, col + 1)
    end
    return pack
end

---@private
---@param buf integer
---@param root TSNode
---@return py.reqs.Pack?
function M.parse_poetry(buf, root)
    -- requests = "==2.0.0"
    -- requests = { version = "==2.0.0" }
    local name = root:named_child(0)
    local version = root:named_child(1)
    if version and version:type() == 'inline_table' then
        for pair in version:iter_children() do
            local key = pair:named_child(0)
            if key and vim.treesitter.get_node_text(key, buf) == 'version' then
                version = pair:named_child(1)
            end
        end
    end
    if not name or not version then
        return nil
    end
    local text = vim.treesitter.get_node_text(name, buf)
        .. vim.treesitter.get_node_text(version, buf):sub(2, -2)
        .. '\n'
    local pack = requirements.line(text)
    if pack then
        local row = version:range()
        -- TODO: need to adjust columns correctly to support completions and
        --       upgrading but is not straight forward, for now nil them out
        --       to avoid writing text in the wrong location
        pack:shift(row, nil)
    end
    return pack
end

---@param str string
---@return py.reqs.Pack?
function M.line(str)
    -- TODO: implement this to support version completions
    return nil
end

return M
