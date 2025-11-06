---@module 'luassert'

local curl = require('py-requirements.lib.curl')
local stub = require('luassert.stub')

describe('curl', function()
    ---@class py.reqs.test.curl.Task: vim.SystemObj
    ---@field private code integer
    ---@field private stdout string
    local Task = {}
    Task.__index = Task

    ---@param code integer
    ---@param stdout string
    ---@return py.reqs.test.curl.Task
    function Task.new(code, stdout)
        local self = setmetatable({}, Task)
        self.code = code
        self.stdout = stdout
        return self
    end

    ---@return vim.SystemCompleted
    function Task:wait()
        ---@type vim.SystemCompleted
        return { code = self.code, signal = 0, stdout = self.stdout }
    end

    ---@param code integer
    ---@param status string
    ---@param body? string
    local function setup(code, status, body)
        stub.new(vim, 'system', function(cmd, opts)
            assert.same('curl', cmd[1])
            assert.same({ text = true }, opts)
            ---@type string[]
            local lines = { ('HTTP/2 %s'):format(status), '', body }
            return Task.new(code, table.concat(lines, '\n') .. '\n')
        end)
    end

    ---@param expected any
    local function validate(expected)
        assert.same(expected, curl.get('test'))
    end

    it('passes 200 response', function()
        local data = { 1, 2, 3 }
        setup(0, '200', vim.json.encode(data))
        validate(data)
    end)

    it('passes 301 response', function()
        local data = { 1, 2, 3 }
        setup(0, '301', vim.json.encode(data))
        validate(data)
    end)

    it('ignores 404 response', function()
        local data = { 1, 2, 3 }
        setup(0, '404', vim.json.encode(data))
        validate(nil)
    end)

    it('ignores non zero exit code', function()
        local data = { 1, 2, 3 }
        setup(1, '200', vim.json.encode(data))
        validate(nil)
    end)

    it('ignores invalid satus', function()
        local data = { 1, 2, 3 }
        setup(0, 'INVALID', vim.json.encode(data))
        validate(nil)
    end)

    it('ignores missing body', function()
        setup(0, '200')
        validate(nil)
    end)

    it('ignores invalid json', function()
        setup(0, '200', 'INVALID')
        validate(nil)
    end)
end)
