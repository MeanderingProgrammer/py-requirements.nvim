local source = require('py-requirements.integrations.source')

---@class py.reqs.integ.Lsp
local M = {}

function M.setup()
    local name = 'py-requirements'
    ---@type vim.lsp.ClientConfig
    local config = {
        name = name,
        cmd = M.server,
    }
    ---@type vim.lsp.start.Opts
    local opts = {
        bufnr = 0,
        reuse_client = function(lsp_client, lsp_config)
            return lsp_client.name == lsp_config.name
        end,
    }
    vim.lsp.start(config, opts)
end

---@private
---@param dispatchers vim.lsp.rpc.Dispatchers
---@return vim.lsp.rpc.PublicClient
function M.server(dispatchers)
    local id = 0
    local closing = false

    ---@type vim.lsp.rpc.PublicClient
    return {
        request = function(method, params, callback)
            if method == 'initialize' then
                callback(nil, {
                    capabilities = {
                        completionProvider = {
                            triggerCharacters = source.trigger_characters(),
                        },
                    },
                })
            elseif method == 'textDocument/completion' then
                vim.schedule(function()
                    callback(nil, M.completions(params))
                end)
            elseif method == 'shutdown' then
                callback(nil, nil)
            end
            id = id + 1
            return true, id
        end,
        notify = function(method)
            if method == 'exit' then
                -- code 0 (success), signal 15 (SIGTERM)
                dispatchers.on_exit(0, 15)
            end
            return true
        end,
        is_closing = function()
            return closing
        end,
        terminate = function()
            closing = true
        end,
    }
end

---@private
---@param params lsp.CompletionParams
---@return lsp.CompletionList?
function M.completions(params)
    local row = params.position.line
    local items = source.completions(row)
    if not items then
        return nil
    end
    ---@type lsp.CompletionList
    return {
        isIncomplete = false,
        items = items,
    }
end

return M
