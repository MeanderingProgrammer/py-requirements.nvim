local api = require('py-requirements.api')
local source = require('py-requirements.integrations.source')

---@class py.reqs.command.Action
---@field label string
---@field method string

local lsp_name = 'py-requirements'
local lsp_command = 'py_command'

---@class py.reqs.integ.Lsp
local M = {}

function M.setup()
    vim.lsp.start({
        name = lsp_name,
        cmd = M.server,
        commands = { [lsp_command] = M.command },
    }, {
        bufnr = 0,
        reuse_client = function(lsp_client, lsp_config)
            return lsp_client.name == lsp_config.name
        end,
    })
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
                        codeActionProvider = true,
                        completionProvider = {
                            triggerCharacters = source.trigger_characters(),
                        },
                        hoverProvider = true,
                    },
                })
            elseif method == 'textDocument/codeAction' then
                callback(nil, M.code_actions())
            elseif method == 'textDocument/completion' then
                M.completions(params, function(list)
                    callback(nil, list)
                end)
            elseif method == 'textDocument/hover' then
                api.show_description()
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
---@param cmd lsp.Command
---@param ctx table<string, any>
function M.command(cmd, ctx)
    local action = api[cmd.title] ---@type any
    if type(action) == 'function' then
        vim.api.nvim_buf_call(ctx.bufnr, action)
    end
end

---@private
---@return lsp.CodeAction[]
function M.code_actions()
    ---@type py.reqs.command.Action[]
    local actions = {
        { label = 'upgrade', method = 'upgrade' },
        { label = 'upgrade all', method = 'upgrade_all' },
    }
    local result = {} ---@type lsp.CodeAction[]
    for _, action in ipairs(actions) do
        result[#result + 1] = {
            title = action.label,
            kind = 'refactor.rewrite',
            command = {
                title = action.method,
                command = lsp_command,
            },
        }
    end
    return result
end

---@private
---@param params lsp.CompletionParams
---@param callback fun(list?: lsp.CompletionList)
function M.completions(params, callback)
    -- lsp position: (0,0)-indexed
    local row = params.position.line
    source.items(row, function(items)
        if not items then
            callback(nil)
        else
            callback({
                isIncomplete = false,
                items = items,
            })
        end
    end)
end

return M
