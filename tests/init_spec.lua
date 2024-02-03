local mock = require('luassert.mock')
local async_tests = require('plenary.async.tests')
local util = require('plenary.async.util')
local ui = require('py-requirements.ui')
local eq = assert.are.same

async_tests.describe('init', function()
    async_tests.before_each(function()
        require('py-requirements').setup({
            enable_cmp = false,
        })
    end)

    async_tests.it('run auto command', function()
        local curl = mock(require('plenary.curl'), true)
        curl.get.returns({
            status = 200,
            body = vim.json.encode({ versions = { '3.2.2' } }),
        })
        vim.cmd('e tests/requirements.txt')
        util.scheduler()
        assert.stub(curl.get).was_called_with('https://pypi.org/simple/argcomplete/', {
            headers = {
                Accept = 'application/vnd.pypi.simple.v1+json',
                ['User-Agent'] = 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)',
            },
            raw = { '--location' },
        })
        local marks = vim.api.nvim_buf_get_extmarks(0, ui.TEXT_NAMESPACE, 0, -1, {})
        eq(1, #marks)
    end)
end)
