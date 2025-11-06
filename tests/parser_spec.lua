---@module 'luassert'

local Package = require('py-requirements.lib.package')
local parser = require('py-requirements.parser')
local util = require('tests.util')

describe('parser', function()
    before_each(function()
        require('py-requirements').setup({})
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
        ---@type py.reqs.Package[]
        local expected = {
            Package.new(
                1,
                'argcomplete',
                '>',
                { value = '3.2.2', col = { 12, 17 } }
            ),
            Package.new(2, 'click', '>=', { value = '8.1.7', col = { 7, 12 } }),
            Package.new(
                3,
                'discord.py',
                '==',
                { value = '2.3', col = { 12, 15 } }
            ),
            Package.new(4, 'numpy', '<=', { value = '0.7.3', col = { 7, 12 } }),
            Package.new(5, 'pandas', '<', { value = '1.1.0', col = { 7, 12 } }),
            Package.new(6, 'plotly'),
            Package.new(7, 'toml'),
            Package.new(
                8,
                'asgiref',
                '==',
                { value = '3.6.0', col = { 9, 14 } }
            ),
        }
        assert.same(expected, parser.packages(buf))
        assert.same(33, parser.max_len(buf, expected))
        assert.same(
            Package.new(0, 'click', '==', { value = '0', col = { 7, 8 } }),
            parser.line('click==')
        )
        assert.same(nil, parser.line('click='))
    end)
end)
