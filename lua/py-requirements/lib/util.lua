---@type table<string, vim.treesitter.Query?>
local cache = {}

---@class py.reqs.Util
local M = {}

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

---@param s string
---@param sep string
---@return string[]
function M.split(s, sep)
    return vim.split(s, sep, { plain = true, trimempty = true })
end

return M
