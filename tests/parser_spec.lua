---@module 'luassert'

local parser = require('py-requirements.parser')
local util = require('tests.util')

describe('parser', function()
    ---@class py.reqs.test.Pack
    ---@field [1] string
    ---@field [2]? string
    ---@field [3]? string
    ---@field [4] integer
    ---@field [5]? Range2

    ---@param pack py.reqs.Pack
    ---@return py.reqs.test.Pack
    local function convert(pack)
        local spec = pack:spec()
        ---@type py.reqs.test.Pack
        return {
            pack.name,
            spec and spec.cmp,
            spec and spec.version,
            pack.row,
            spec and spec.cols,
        }
    end

    ---@param buf integer
    ---@return py.reqs.test.Pack[]
    local function parse_buf(buf)
        local result = {} ---@type py.reqs.test.Pack[]
        for _, pack in ipairs(parser.buf(buf)) do
            result[#result + 1] = convert(pack)
        end
        util.delete(buf)
        return result
    end

    ---@param buf integer
    ---@param str string
    ---@return py.reqs.test.Pack?
    local function parse_line(buf, str)
        local pack = parser.line(buf, str)
        util.delete(buf)
        return pack and convert(pack)
    end

    describe('requirements', function()
        local filetype = 'requirements'

        describe('buf', function()
            ---@param lines string[]
            ---@param expected py.reqs.test.Pack[]
            local function validate(lines, expected)
                local buf = util.create(filetype, lines)
                local actual = parse_buf(buf)
                assert.same(expected, actual)
            end

            it('name', function()
                validate({ 'toml' }, { { 'toml', nil, nil, 0, nil } })
            end)

            it('version', function()
                validate(
                    { 'click==8.1.7' },
                    { { 'click', '==', '8.1.7', 0, { 7, 12 } } }
                )
            end)

            it('comments', function()
                validate(
                    { '# Comment Line', 'argcomplete>3.2.2 # Comment After' },
                    { { 'argcomplete', '>', '3.2.2', 1, { 12, 17 } } }
                )
            end)

            it('hashes', function()
                validate({
                    'asgiref>=3.6.0 \\',
                    '    --hash=sha256:71e68008da809b957b7ee4b43dbccff33d1b23519fb8344e33f049897077afac \\',
                    '    --hash=sha256:9567dfe7bd8d3c8c892227827c41cce860b368104c3431da67a0c5a65a949506',
                    '    # via django',
                }, { { 'asgiref', '>=', '3.6.0', 0, { 9, 14 } } })
            end)
        end)

        describe('line', function()
            ---@param str string
            ---@param expected py.reqs.test.Pack?
            local function validate(str, expected)
                local buf = util.create(filetype, {})
                local actual = parse_line(buf, str)
                assert.same(expected, actual)
            end

            it('valid', function()
                validate('click==', { 'click', '==', '0', 0, { 7, 8 } })
            end)

            it('invalid', function()
                validate('click=', nil)
            end)
        end)
    end)

    describe('toml', function()
        local filetype = 'toml'

        describe('buf', function()
            ---@param lines string[]
            ---@param expected py.reqs.test.Pack[]
            local function validate(lines, expected)
                local buf = util.create(filetype, lines)
                local actual = parse_buf(buf)
                assert.same(expected, actual)
            end

            it('project dependencies name', function()
                validate(
                    { '[project]', 'dependencies = ["toml"]' },
                    { { 'toml', nil, nil, 1, nil } }
                )
            end)

            it('project dependencies version', function()
                validate(
                    { '[project]', 'dependencies = ["click==8.1.7"]' },
                    { { 'click', '==', '8.1.7', 1, { 24, 29 } } }
                )
            end)

            it('dependency-groups', function()
                validate(
                    { '[dependency-groups]', 'name = ["click>=8.1.7"]' },
                    { { 'click', '>=', '8.1.7', 1, { 16, 21 } } }
                )
            end)

            it('project optional-dependencies', function()
                validate({
                    '[project.optional-dependencies]',
                    'name = ["click<=8.1.7"]',
                }, { { 'click', '<=', '8.1.7', 1, { 16, 21 } } })
            end)

            it('poetry version string', function()
                validate(
                    { '[tool.poetry.dependencies]', 'click = ">8.1.7"' },
                    { { 'click', '>', '8.1.7', 1, nil } }
                )
            end)

            it('poetry version table', function()
                validate({
                    '[tool.poetry.dependencies]',
                    'click = { version = ">8,<8.1.7" }',
                }, { { 'click', '<', '8.1.7', 1, nil } })
            end)
        end)
    end)
end)
