---@module 'luassert'

local parser = require('py-requirements.parser')
local util = require('tests.util')

local eq = assert.are.same

describe('parser', function()
    before_each(function()
        require('py-requirements').setup({
            enable_cmp = false,
        })
    end)

    it('parse requirements', function()
        local buf = util.create_file('requirements.txt', {
            '# Comment Line',
            'argcomplete>3.2.2 # Comment After',
            'click>=8.1.7',
            'discord.py==2.3',
            'numpy<=0.7.3',
            'pandas<1.1.0',
            'plotly!=',
            'toml',
            'asgiref==3.6.0 \\',
            '    --hash=sha256:71e68008da809b957b7ee4b43dbccff33d1b23519fb8344e33f049897077afac \\',
            '    --hash=sha256:9567dfe7bd8d3c8c892227827c41cce860b368104c3431da67a0c5a65a949506',
            '    # via django',
        })
        local expected = {
            {
                line_number = 1,
                name = 'argcomplete',
                comparison = '>',
                version = { value = '3.2.2', start_col = 12, end_col = 17 },
                versions = { status = 1, values = {} },
            },
            {
                line_number = 2,
                name = 'click',
                comparison = '>=',
                version = { value = '8.1.7', start_col = 7, end_col = 12 },
                versions = { status = 1, values = {} },
            },
            {
                line_number = 3,
                name = 'discord.py',
                comparison = '==',
                version = { value = '2.3', start_col = 12, end_col = 15 },
                versions = { status = 1, values = {} },
            },
            {
                line_number = 4,
                name = 'numpy',
                comparison = '<=',
                version = { value = '0.7.3', start_col = 7, end_col = 12 },
                versions = { status = 1, values = {} },
            },
            {
                line_number = 5,
                name = 'pandas',
                comparison = '<',
                version = { value = '1.1.0', start_col = 7, end_col = 12 },
                versions = { status = 1, values = {} },
            },
            {
                line_number = 6,
                name = 'plotly',
                versions = { status = 1, values = {} },
            },
            {
                line_number = 7,
                name = 'toml',
                versions = { status = 1, values = {} },
            },
            {
                line_number = 8,
                name = 'asgiref',
                comparison = '==',
                version = { value = '3.6.0', start_col = 9, end_col = 14 },
                versions = { status = 1, values = {} },
            },
        }
        eq(expected, parser.modules(buf))
        eq(33, parser.max_len(buf, expected))
        eq({
            line_number = 0,
            name = 'click',
            comparison = '==',
            version = { value = '0', start_col = 7, end_col = 8 },
            versions = { status = 1, values = {} },
        }, parser.module_string('click=='))
        eq(nil, parser.module_string('click='))
    end)
end)
