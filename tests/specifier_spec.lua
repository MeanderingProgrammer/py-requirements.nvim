---@module 'luassert'

local specifier = require('py-requirements.lib.specifier')

describe('specifier', function()
    local base = '1.0.0'

    ---@type table<string, table<string, boolean>>
    local cases = {
        ['=='] = {
            ['0.9.0'] = false,
            ['1.0.0'] = true,
            ['1.1.0'] = false,
        },
        ['==='] = {
            ['0.9.0'] = false,
            ['1.0.0'] = true,
            ['1.1.0'] = false,
        },
        ['<'] = {
            ['0.9.0'] = false,
            ['1.0.0'] = false,
            ['1.1.0'] = true,
        },
        ['<='] = {
            ['0.9.0'] = false,
            ['1.0.0'] = true,
            ['1.1.0'] = true,
        },
        ['>'] = {
            ['0.9.0'] = true,
            ['1.0.0'] = false,
            ['1.1.0'] = false,
        },
        ['>='] = {
            ['0.9.0'] = true,
            ['1.0.0'] = true,
            ['1.1.0'] = false,
        },
        ['~='] = {
            ['0.9.0'] = false,
            ['1.0.0'] = true,
            ['1.1.0'] = false,
        },
    }

    for cmp, data in pairs(cases) do
        it(cmp, function()
            for version, expected in pairs(data) do
                local actual = specifier.matches(base, cmp, version)
                local message = ('%s %s %s'):format(base, cmp, version)
                assert.same(expected, actual, message)
            end
        end)
    end
end)
