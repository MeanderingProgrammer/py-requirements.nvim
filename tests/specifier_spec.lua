---@module 'luassert'

local specifier = require('py-requirements.lib.specifier')

describe('specifier', function()
    local base = '1.0.0'

    ---@type table<string, table<string, boolean>>
    local cases = {
        ['==='] = {
            ['0'] = false,
            ['1'] = true,
            ['2'] = false,
            ['0.9'] = false,
            ['1.0'] = true,
            ['1.1'] = false,
            ['0.9.0'] = false,
            ['1.0.0'] = true,
            ['1.1.0'] = false,
        },
        ['=='] = {
            ['0'] = false,
            ['1'] = true,
            ['2'] = false,
            ['0.9'] = false,
            ['1.0'] = true,
            ['1.1'] = false,
            ['0.9.0'] = false,
            ['1.0.0'] = true,
            ['1.1.0'] = false,
        },
        ['!='] = {
            ['0'] = true,
            ['1'] = false,
            ['2'] = true,
            ['0.9'] = true,
            ['1.0'] = false,
            ['1.1'] = true,
            ['0.9.0'] = true,
            ['1.0.0'] = false,
            ['1.1.0'] = true,
        },
        ['<'] = {
            ['0'] = false,
            ['1'] = false,
            ['2'] = true,
            ['0.9'] = false,
            ['1.0'] = false,
            ['1.1'] = true,
            ['0.9.0'] = false,
            ['1.0.0'] = false,
            ['1.1.0'] = true,
        },
        ['<='] = {
            ['0'] = false,
            ['1'] = true,
            ['2'] = true,
            ['0.9'] = false,
            ['1.0'] = true,
            ['1.1'] = true,
            ['0.9.0'] = false,
            ['1.0.0'] = true,
            ['1.1.0'] = true,
        },
        ['>'] = {
            ['0'] = true,
            ['1'] = false,
            ['2'] = false,
            ['0.9'] = true,
            ['1.0'] = false,
            ['1.1'] = false,
            ['0.9.0'] = true,
            ['1.0.0'] = false,
            ['1.1.0'] = false,
        },
        ['>='] = {
            ['0'] = true,
            ['1'] = true,
            ['2'] = false,
            ['0.9'] = true,
            ['1.0'] = true,
            ['1.1'] = false,
            ['0.9.0'] = true,
            ['1.0.0'] = true,
            ['1.1.0'] = false,
        },
        ['~='] = {
            ['0'] = false,
            ['1'] = true,
            ['2'] = false,
            ['0.9'] = false,
            ['1.0'] = true,
            ['1.1'] = false,
            ['0.9.0'] = false,
            ['1.0.0'] = true,
            ['1.1.0'] = false,
        },
    }

    for cmp, data in pairs(cases) do
        for version, expected in pairs(data) do
            it(('%s %s %s'):format(base, cmp, version), function()
                local actual = specifier.matches(base, cmp, version)
                assert.same(expected, actual)
            end)
        end
    end
end)
