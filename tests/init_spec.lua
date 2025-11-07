---@module 'luassert'

local mock = require('luassert.mock')
local ui = require('py-requirements.lib.ui')
local util = require('tests.util')

local pypi = mock(require('py-requirements.lib.pypi'), true)

describe('init', function()
    before_each(function()
        util.setup({})
    end)

    after_each(function()
        pypi.get_versions:clear()
    end)

    ---@param packages table<string, string[]>
    local function setup(packages)
        for name, versions in pairs(packages) do
            ---@type py.reqs.pypi.Versions
            local response = { values = versions, files = {} }
            pypi.get_versions.on_call_with(name).returns(response)
        end
    end

    ---@class py.reqs.test.Diagnostic
    ---@field line integer
    ---@field text string
    ---@field prefix string

    ---@param filetype py.reqs.test.Filetype
    ---@param lines string[]
    ---@param expected py.reqs.test.Diagnostic[]
    local function validate(filetype, lines, expected)
        local buf = util.create(filetype, lines)
        vim.wait(0)

        local diagnostics = vim.diagnostic.get(buf, { namespace = ui.ns })
        util.delete(buf)

        local actual = {} ---@type py.reqs.test.Diagnostic[]
        for _, diagnostic in ipairs(diagnostics) do
            actual[#actual + 1] = {
                line = diagnostic.lnum,
                text = diagnostic.message,
                prefix = ui.prefix(diagnostic),
            }
        end

        assert.same(expected, actual)
        assert.stub(pypi.get_versions).was.called(4)
    end

    it('requirements', function()
        setup({
            ['argcomplete'] = { '3.2.2' },
            ['pandas'] = { '2.1.0', '2.2.0' },
        })
        validate('requirements', { 'argcomplete==3.2.2', 'pandas==2.1.0' }, {
            { line = 0, text = '3.2.2', prefix = ' ' },
            { line = 1, text = '2.2.0', prefix = ' ' },
        })
    end)

    it('toml', function()
        setup({
            ['argcomplete'] = { '3.2.2' },
            ['pandas'] = { '2.1.0', '2.2.0' },
        })
        validate('toml', {
            '[project]',
            'dependencies = [',
            '  "argcomplete==3.2.2",',
            '  "pandas==2.1.0",',
            ']',
        }, {
            { line = 2, text = '3.2.2', prefix = ' ' },
            { line = 3, text = '2.2.0', prefix = ' ' },
        })
    end)
end)
