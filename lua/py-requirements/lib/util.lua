---@type table<string, vim.treesitter.Query?>
local cache = {}

---@class py.reqs.Util
local M = {}

---@param source integer|string
---@param lang string
---@return TSNode?
function M.root(source, lang)
    local ok = nil ---@type boolean?
    local tree = nil ---@type vim.treesitter.LanguageTree?
    if type(source) == 'number' then
        ok, tree = pcall(vim.treesitter.get_parser, source, lang)
    else
        ok, tree = pcall(vim.treesitter.get_string_parser, source, lang)
    end
    return ok and tree and tree:parse()[1]:root() or nil
end

---@param lang string
---@param query string
---@return vim.treesitter.Query?
function M.query(lang, query)
    if not cache[query] then
        local ok, result = pcall(vim.treesitter.query.parse, lang, query)
        cache[query] = ok and result or nil
    end
    return cache[query]
end

---@return integer
function M.buffer()
    return vim.api.nvim_get_current_buf()
end

---@return integer
function M.row()
    -- nvim_win_get_cursor: (1,0)-indexed
    return vim.api.nvim_win_get_cursor(0)[1] - 1
end

---@param s string
---@param sep string
---@return string[]
function M.split(s, sep)
    return vim.split(s, sep, { plain = true, trimempty = true })
end

return M
