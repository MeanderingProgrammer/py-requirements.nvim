local async_tests = require('plenary.async.tests')
local mock = require('luassert.mock')
local ui = require('py-requirements.ui')
local util = require('plenary.async.util')

local api = mock(require('py-requirements.api'), true)
local eq = assert.are.same

---@param name string
---@param versions string[]
local function set_response(name, versions)
    api.get_versions.on_call_with(name, false).returns({
        status = api.ModuleStatus.VALID,
        values = versions,
    })
end

async_tests.describe('init', function()
    async_tests.before_each(function()
        require('py-requirements').setup({
            enable_cmp = false,
        })
    end)

    async_tests.it('run auto command', function()
        set_response('argcomplete', { '3.2.2' })
        set_response('pandas', { '2.1.0', '2.2.0' })

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
