---@module 'luassert'

local mock = require('luassert.mock')
local pypi = require('py-requirements.pypi')
local util = require('tests.util')

local curl = mock(require('py-requirements.curl'), true)
local eq = assert.are.same

---@param name string
---@param status integer
---@param versions string[]
---@param files table[]?
local function set_response(name, status, versions, files)
    local endpoint = string.format('https://pypi.org/simple/%s/', name)
    local repo = 'py-requirements.nvim'
    local user_agent = string.format(
        '%s (https://github.com/MeanderingProgrammer/%s)',
        repo,
        repo
    )
    local request_headers = { Accept = 'application/vnd.pypi.simple.v1+json' }
    curl.get
        .on_call_with(endpoint, '-isSL', user_agent, request_headers)
        .returns({
            status = status,
            body = vim.json.encode({ versions = versions, files = files }),
        })
end

describe('api', function()
    after_each(function()
        curl.get:clear()
    end)

    it('versions status 200', function()
        util.setup({})

        local name = 't1'
        local versions = { '3.2.2', '3.2.2.post1' }
        set_response(name, 200, versions, nil)

        local expected = { status = pypi.Status.VALID, values = versions }
        eq(expected, pypi.get_versions(name))
        assert.stub(curl.get).was.called(1)
    end)

    it('versions status 200 final release', function()
        util.setup({ filter = { final_release = true } })

        local name = 't2'
        set_response(name, 200, {
            '2.3.0a1', -- Alpha release
            '2.3.0b2', -- Beta release
            '2.3.0rc3', -- Release Candidate
            '2.3.0.dev1', -- Developmental release
            '2.3.0', -- Final release
            '2.3.0.post1', -- Post-release
        }, nil)

        local expected = { status = pypi.Status.VALID, values = { '2.3.0' } }
        eq(expected, pypi.get_versions(name))
        assert.stub(curl.get).was.called(1)
    end)

    it('versions status 200 yanked', function()
        util.setup({})

        local name = 't3'
        set_response(name, 200, { '3.2.2', '3.2.3', '3.2.4' }, {
            { filename = name .. '-3.2.3.tar.gz', yanked = false },
            { filename = name .. '-3.2.4.tar.gz', yanked = 'Reason for yank' },
        })

        local expected = {
            status = pypi.Status.VALID,
            values = { '3.2.2', '3.2.3' },
        }
        eq(expected, pypi.get_versions(name))
        assert.stub(curl.get).was.called(1)
    end)

    it('versions status 200 yanked disabled', function()
        util.setup({ filter = { yanked = false } })

        local name = 't4'
        local versions = { '3.2.2', '3.2.3', '3.2.4' }
        set_response(name, 200, versions, {
            { filename = name .. '-3.2.3.tar.gz', yanked = false },
            { filename = name .. '-3.2.4.tar.gz', yanked = 'Reason for yank' },
        })

        local expected = { status = pypi.Status.VALID, values = versions }
        eq(expected, pypi.get_versions(name))
        assert.stub(curl.get).was.called(1)
    end)

    it('versions status 301 with cache', function()
        util.setup({})

        local name = 't5'
        local versions = { '2.1.0', '2.2.0b1', '2.2.0' }
        set_response(name, 301, versions, nil)

        local expected = { status = pypi.Status.VALID, values = versions }
        eq(expected, pypi.get_versions(name))
        assert.stub(curl.get).was.called(1)

        eq(expected, pypi.get_versions(name))
        eq(expected, pypi.get_versions(name))
        eq(expected, pypi.get_versions(name))
        assert.stub(curl.get).was.called(1)
    end)

    it('versions status 404', function()
        util.setup({})

        local name = 't6'
        set_response(name, 404, { '1.0.0', '2.0.0' }, nil)

        eq(pypi.FAILED, pypi.get_versions(name))
        assert.stub(curl.get).was.called(1)
    end)
end)
