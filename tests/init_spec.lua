---@module 'luassert'

local mock = require('luassert.mock')
local ui = require('py-requirements.ui')
local util = require('tests.util')

local pypi = mock(require('py-requirements.pypi'), true)
local eq = assert.are.same

---@param name string
---@param versions string[]
local function set_response(name, versions)
    pypi.get_versions.on_call_with(name).returns({
        status = pypi.Status.VALID,
        values = versions,
    })
end

describe('init', function()
    it('run auto command', function()
        set_response('argcomplete', { '3.2.2' })
        set_response('pandas', { '2.1.0', '2.2.0' })

        util.setup({}, 'tests/requirements.txt')

        local actual = {}
        local diagnostics = vim.diagnostic.get(0, { namespace = ui.namespace })
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
        assert.stub(pypi.get_versions).was.called(4)
    end)
end)
