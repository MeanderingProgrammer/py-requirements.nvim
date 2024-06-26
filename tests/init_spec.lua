local async_tests = require('plenary.async.tests')
local mock = require('luassert.mock')
local ui = require('py-requirements.ui')
local util = require('plenary.async.util')

local api = mock(require('py-requirements.api'), true)
local eq = assert.are.same

---@param name string
---@param versions string[]
local function set_response(name, versions)
    api.get_versions.on_call_with(name).returns({
        status = api.ModuleStatus.VALID,
        values = versions,
    })
end

async_tests.describe('init', function()
    async_tests.before_each(function()
        require('py-requirements').setup({
            enable_cmp = false,
        })
    end)

    async_tests.it('run auto command', function()
        set_response('argcomplete', { '3.2.2' })
        set_response('pandas', { '2.1.0', '2.2.0' })

        vim.cmd('e tests/requirements.txt')
        util.scheduler()

        local actual = {}
        local diagnostics = vim.diagnostic.get(0, { namespace = ui.NAMESPACE })
        for _, diagnostic in ipairs(diagnostics) do
            local diagnostic_info = {
                line = diagnostic.lnum,
                text = diagnostic.message,
                prefix = ui.prefix(diagnostic),
            }
            table.insert(actual, diagnostic_info)
        end

        local expected = {
            { line = 0, text = '3.2.2', prefix = ' ' },
            { line = 1, text = '2.2.0', prefix = ' ' },
        }

        eq(expected, actual)
        assert.stub(api.get_versions).was.called(4)
    end)
end)
