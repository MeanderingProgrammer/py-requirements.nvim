local mock = require('luassert.mock')
local api = require('py-requirements.api')

local curl = mock(require('plenary.curl'), true)
local eq = assert.are.same

---@param name string
---@param status integer
---@param versions string[]
local function set_response(name, status, versions)
    curl.get
        .on_call_with(string.format('https://pypi.org/simple/%s/', name), {
            headers = {
                ['Accept'] = 'application/vnd.pypi.simple.v1+json',
                ['User-Agent'] = 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)',
            },
            raw = { '--location' },
        })
        .returns({ status = status, body = vim.json.encode({ versions = versions }) })
end

describe('api', function()
    after_each(function()
        curl.get:clear()
    end)

    it('versions status 200', function()
        local versions = { '3.2.2', '3.2.2.post1' }
        set_response('t1', 200, versions)

        local expected = { status = api.ModuleStatus.VALID, values = versions }
        eq(expected, api.get_versions('t1', false))
        assert.stub(curl.get).was.called(1)
    end)

    it('versions status 200 release only', function()
        set_response('t2', 200, {
            '2.3.0a1', -- Alpha release
            '2.3.0b2', -- Beta release
            '2.3.0rc3', -- Release Candidate
            '2.3.0.dev1', -- Developmental release
            '2.3.0', -- Final release
            '2.3.0.post1', -- Post-release
        })

        local expected = { status = api.ModuleStatus.VALID, values = { '2.3.0' } }
        eq(expected, api.get_versions('t2', true))
        assert.stub(curl.get).was.called(1)
    end)

    it('versions status 301 with cache', function()
        local versions = { '2.1.0', '2.2.0b1', '2.2.0' }
        set_response('t3', 301, versions)

        local expected = { status = api.ModuleStatus.VALID, values = versions }
        eq(expected, api.get_versions('t3', false))
        assert.stub(curl.get).was.called(1)

        eq(expected, api.get_versions('t3', false))
        eq(expected, api.get_versions('t3', false))
        eq(expected, api.get_versions('t3', false))
        assert.stub(curl.get).was.called(1)
    end)

    it('versions status 404', function()
        set_response('t4', 404, { '1.0.0', '2.0.0' })

        eq(api.FAILED, api.get_versions('t4', false))
        assert.stub(curl.get).was.called(1)
    end)
end)
