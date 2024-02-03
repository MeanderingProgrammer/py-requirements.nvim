local mock = require('luassert.mock')
local async_tests = require('plenary.async.tests')
local util = require('plenary.async.util')
local ui = require('py-requirements.ui')
local eq = assert.are.same

---@param name string
---@param versions string[]
local function set_response(curl, name, versions)
    curl.get
        .on_call_with(string.format('https://pypi.org/simple/%s/', name), {
            headers = {
                Accept = 'application/vnd.pypi.simple.v1+json',
                ['User-Agent'] = 'py-requirements.nvim (https://github.com/MeanderingProgrammer/py-requirements.nvim)',
            },
            raw = { '--location' },
        })
        .returns({
            status = 200,
            body = vim.json.encode({ versions = versions }),
        })
end

async_tests.describe('init', function()
    async_tests.before_each(function()
        require('py-requirements').setup({
            enable_cmp = false,
        })
    end)

    async_tests.it('run auto command', function()
        local curl = mock(require('plenary.curl'), true)
        set_response(curl, 'argcomplete', { '3.2.2' })
        set_response(curl, 'pandas', { '2.1.0', '2.2.0' })

        vim.cmd('e tests/requirements.txt')
        util.scheduler()

        local mark_details = {}
        local marks = vim.api.nvim_buf_get_extmarks(0, ui.TEXT_NAMESPACE, 0, -1, { details = true })
        for _, mark in ipairs(marks) do
            local _, row, _, details = unpack(mark)
            table.insert(mark_details, {
                pos = { row, details.virt_text_win_col },
                text = details.virt_text[1][1],
            })
        end
        local expected = {
            { pos = { 0, 23 }, text = ' 3.2.2' },
            { pos = { 1, 23 }, text = ' 2.2.0' },
        }
        eq(expected, mark_details)
    end)
end)
