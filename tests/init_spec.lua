local mock = require('luassert.mock')
local async_tests = require('plenary.async.tests')
local util = require('plenary.async.util')
local ui = require('py-requirements.ui')

local api = mock(require('py-requirements.api'), true)
local eq = assert.are.same

async_tests.describe('init', function()
    async_tests.before_each(function()
        require('py-requirements').setup({
            enable_cmp = false,
        })
    end)

    async_tests.it('run auto command', function()
        api.get_versions.on_call_with('argcomplete').returns({
            status = api.ModuleStatus.VALID,
            values = { '3.2.2' },
        })
        api.get_versions.on_call_with('pandas').returns({
            status = api.ModuleStatus.VALID,
            values = { '2.1.0', '2.2.0' },
        })

        vim.cmd('e tests/requirements.txt')
        util.scheduler()

        local actual = {}
        local marks = vim.api.nvim_buf_get_extmarks(0, ui.TEXT_NAMESPACE, 0, -1, { details = true })
        for _, mark in ipairs(marks) do
            local _, row, _, details = unpack(mark)
            table.insert(actual, {
                pos = { row, details.virt_text_win_col },
                text = details.virt_text[1][1],
            })
        end
        local expected = {
            { pos = { 0, 23 }, text = ' 3.2.2' },
            { pos = { 1, 23 }, text = ' 2.2.0' },
        }
        eq(expected, actual)
        assert.stub(api.get_versions).was.called(4)
    end)
end)
