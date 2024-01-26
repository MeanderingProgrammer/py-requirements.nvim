# py-requirements.nvim

Neovim plugin that helps manage python requirements.

https://github.com/MeanderingProgrammer/py-requirements.nvim/assets/52591095/6ffce2f2-b1e6-4191-9cbe-e968e7766a97

# Features

- Integrated with `nvim-cmp`
- Uses `treesitter` parser to read `requirements.txt`, hopefully more robust than
  ad-hoc string manipulation
- Displays diagnostics in `normal` mode with warnings for not using latest version
- Cache `pypi` responses within a session to improve performance

# Dependencies

- `curl` on your system: Used to get version information from pypi
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim): Used to run `curl` command
- [requirements](https://github.com/ObserverOfTime/tree-sitter-requirements) parser for
  [treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/master): Used to
  parse `requirements.txt` file.

# Install

## Lazy.nvim

```lua
{
    'MeanderingProgrammer/py-requirements.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('py-requirements').setup({
            -- Enabled by default if you do not use `nvim-cmp` set to false
            enable_cmp = true,
        })
    end,
}
```

## Install `requirements` Parser

```lua
require('nvim-treesitter.configs').setup({
    ...
    ensure_installed = {
        ...
        'requirements',
        ...
    },
    ...
})
```

## Add Completion Source

```lua
local cmp = require('cmp')
cmp.setup({
    ...
    sources = cmp.config.sources({
        ...
        { name = 'py-requirements' },
        ...
    }),
    ...
})
```

# Related Projects

- [crates.nvim](https://github.com/Saecki/crates.nvim): Many ideas were taken from this
  project and translated to work with Python modules rather than Rust crates.
- [cmp-pypi](https://github.com/vrslev/cmp-pypi): Found this one rather late, similar
  idea but built to work with `pyproject.toml` files.
