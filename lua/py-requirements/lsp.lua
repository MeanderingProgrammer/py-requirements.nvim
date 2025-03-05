local shared = require('py-requirements.integrations.shared')

---@class py.reqs.Lsp
---@field private id? integer
local M = {
    id = nil,
}

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
    local id = vim.lsp.start(config, opts)
    if id ~= nil then
        M.id = id
    end
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
                            triggerCharacters = shared.trigger_characters(),
                        },
                    },
                })
            elseif method == 'textDocument/completion' then
                local row = params.position.line
                vim.schedule(function()
                    local items = shared.completions(row)
                    if items == nil then
                        callback(nil, nil)
                    else
                        ---@type lsp.CompletionList
                        local completions = {
                            isIncomplete = false,
                            items = items,
                        }
                        callback(nil, completions)
                    end
                end)
            elseif method == 'shutdown' then
                callback(nil, nil)
            end
            id = id + 1
            return true, id
        end,
        notify = function(method)
            if method == 'exit' then
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

return M
