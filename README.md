# py-requirements.nvim

Neovim plugin that helps manage python requirements.

# Dependencies

* `curl` on your system: Used to get version information from pypi
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim): Used to run `curl` command
* [requirements](https://github.com/ObserverOfTime/tree-sitter-requirements) parser for
  [treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/master): Used to
  parse `requirements.txt` file.

# Related projects

* [crates.nvim](https://github.com/Saecki/crates.nvim): Many ideas were taken from this
  project and translated to work with Python modules rather than Rust crates.
* [cmp-pypi](https://github.com/vrslev/cmp-pypi): Found this one rather late, similar
  idea but built to work for `pyproject.toml` files.
