---@module 'luassert'

local mock = require('luassert.mock')
local pypi = require('py-requirements.lib.pypi')
local util = require('tests.util')

local curl = mock(require('py-requirements.lib.curl'), true)

describe('pypi', function()
    local name ---@type string
    before_each(function()
        name = ('t%d'):format(math.random(100000))
    end)

    after_each(function()
        curl.get:clear()
    end)

    describe('versions', function()
        ---@param response py.reqs.pypi.package.Response
        local function setup(response)
            local endpoint = ('https://pypi.org/simple/%s/'):format(name)
            local headers = { Accept = 'application/vnd.pypi.simple.v1+json' }
            curl.get.on_call_with(endpoint, headers).returns(response)
        end

        ---@param expected py.reqs.pypi.Versions
        local function validate(expected)
            -- first call fetches
            assert.same(expected, pypi.get_versions(name))
            assert.stub(curl.get).was.called(1)

            -- subsequent calls uses cache
            for _ = 1, 10 do
                assert.same(expected, pypi.get_versions(name))
            end
            assert.stub(curl.get).was.called(1)
        end

        it('valid', function()
            util.setup({})
            setup({
                versions = { '3.2.2', '3.2.2.post1' },
                files = {},
            })
            validate({ values = { '3.2.2', '3.2.2.post1' } })
        end)

        it('no response', function()
            util.setup({})
            validate({})
        end)

        it('final release filter enabled', function()
            util.setup({ filter = { final_release = true } })
            setup({
            -- stylua: ignore
            versions = {
                '2.3.0a1',     -- Alpha release
                '2.3.0b2',     -- Beta release
                '2.3.0rc3',    -- Release candidate
                '2.3.0.dev1',  -- Developmental release
                '2.3.0',       -- Final release
                '2.3.0.post1', -- Post release
            },
                files = {},
            })
            validate({ values = { '2.3.0' } })
        end)

        it('yanked filter default', function()
            util.setup({})
            setup({
                versions = { '3.2.2', '3.2.3', '3.2.4' },
                files = {
                    { filename = name .. '-3.2.3.tar.gz', yanked = false },
                    { filename = name .. '-3.2.4.tar.gz', yanked = 'Reason' },
                },
            })
            validate({ values = { '3.2.2', '3.2.3' } })
        end)

        it('yanked filter disabled', function()
            util.setup({ filter = { yanked = false } })
            setup({
                versions = { '3.2.2', '3.2.3', '3.2.4' },
                files = {
                    { filename = name .. '-3.2.3.tar.gz', yanked = false },
                    { filename = name .. '-3.2.4.tar.gz', yanked = 'Reason' },
                },
            })
            validate({ values = { '3.2.2', '3.2.3', '3.2.4' } })
        end)
    end)
end)
