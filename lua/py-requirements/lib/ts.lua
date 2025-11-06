---@type table<string, vim.treesitter.Query?>
local cache = {}

---@class py.reqs.Ts
local M = {}

---@param lang string
---@param query string
---@return vim.treesitter.Query?
function M.parse(lang, query)
    if not cache[query] then
        local ok, result = pcall(vim.treesitter.query.parse, lang, query)
        cache[query] = ok and result or nil
    end
    return cache[query]
end

return M
