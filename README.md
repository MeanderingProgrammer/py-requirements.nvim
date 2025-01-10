# py-requirements.nvim

Neovim plugin that helps manage python requirements.

https://github.com/user-attachments/assets/d4aef6a7-deed-4c80-8db6-7d1499e11c64

# Features

- Integrated with `nvim-cmp` and `blink.nvim`
- Uses `treesitter` parser to read `requirements.txt`, more robust than ad-hoc parsing
- Displays diagnostics in `normal` mode with warnings for not using latest version
- Cache `pypi` responses within a session to improve performance
- Auto upgrade dependencies when keymaps are configured
- Display package description from PyPI in a floating window with syntax highlighting
- Supports custom `index-url` and `extra-index-url` for finding packages

# Limitations

- Only supports `requirements.txt` files, if there's interest this can be
  expanded, more details in [ISSUE-10](https://github.com/MeanderingProgrammer/py-requirements.nvim/issues/10)
- Does not read or otherwise interact with `pip.conf` file

# Dependencies

- neovim `>= 0.10.0`
- [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) parser:
  - [requirements](https://github.com/ObserverOfTime/tree-sitter-requirements):
    Used to parse `requirements` files
- System dependencies:
  - `curl`: Used to call pypi API

# Install

## lazy.nvim

```lua
{
    'MeanderingProgrammer/py-requirements.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
        require('py-requirements').setup({})
    end,
}
```

# Setup

## Configure

Below is the default configuration, any part of it can be modified.

```lua
require('py-requirements').setup({
    -- Enabled by default if you do not use `nvim-cmp` set to false
    enable_cmp = true,
    -- Endpoint used for getting package versions
    index_url = 'https://pypi.org/simple/',
    -- Fallback endpoint in case 'index_url' fails to find a package
    extra_index_url = nil,
    -- Specify which file patterns plugin is active on
    -- For info on patterns, see :h pattern
    file_patterns = { 'requirements.txt' },
    -- Options for how diagnsotics are displayed
    diagnostic_opts = { padding = 5 },
    -- For available options, see :h vim.lsp.util.open_floating_preview
    float_opts = { border = 'rounded' },
    filter = {
        -- If set to true pull only final release versions, this will ignore alpha,
        -- beta, release candidate, post release, and developmental release versions
        final_release = false,
        -- If set to true (default value) filter out yanked package versions
        yanked = true,
    },
    -- Query to get each dependency present in a file
    requirement_query = '(requirement) @requirement',
    -- Query to get information out of each dependency
    dependency_query = [[
        (requirement (package) @name)
        (version_spec (version_cmp) @cmp)
        (version_spec (version) @version)
    ]],
})
```

## Keymaps

```lua
local requirements = require('py-requirements')
requirements.setup({...})
vim.keymap.set('n', '<leader>ru', requirements.upgrade, { silent = true, desc = 'Requirements: Upgrade' })
vim.keymap.set('n', '<leader>rU', requirements.upgrade_all, { silent = true, desc = 'Requirements: Upgrade All' })
vim.keymap.set('n', '<leader>rK', requirements.show_description, { silent = true, desc = 'Requirements: Show package description' })
```

## Completions

### nvim-cmp

```lua
local cmp = require('cmp')
cmp.setup({
    sources = cmp.config.sources({
        { name = 'py-requirements' },
    }),
})
```

### blink.cmp

```lua
require('blink.cmp').setup({
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'pypi' },
        providers = {
            pypi = {
                name = 'Pypi',
                module = 'py-requirements.integrations.blink',
                fallbacks = { 'lsp' },
            },
        },
    },
})
```

# Related Projects

- [crates.nvim](https://github.com/Saecki/crates.nvim): Many ideas were taken from
  this project and translated to work with Python dependencies rather than Rust crates
- [cmp-pypi](https://github.com/vrslev/cmp-pypi): Found this one rather late, similar
  idea but built to work with `pyproject.toml` files
