-- Plugin declarations, managed by Neovim's built-in vim.pack.
--
-- Payloads live in ~/.local/share/nvim/site/pack/core/opt; resolved revisions
-- go to nvim-pack-lock.json in this directory, which is committed. Update
-- everything with :lua vim.pack.update().
--
-- vim.pack does no dependency resolution, so anything a plugin needs has to be
-- listed here explicitly. That is a deliberate factor in the choices below.
--
-- During init.lua sourcing vim.pack.add defaults to load = false, which behaves
-- like :packadd! — plugins are on 'runtimepath' right away so require() works,
-- while their plugin/ files are sourced at the normal point in startup.

vim.pack.add({
  -- master is frozen upstream and does not support Neovim 0.12.
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },

  -- Tracking a semver tag rather than the branch: blink only ships the
  -- prebuilt Rust fuzzy matcher on tagged releases. A range keeps updates
  -- flowing without hand-bumping a pinned tag.
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },

  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
  { src = 'https://github.com/ibhagwan/fzf-lua' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
  { src = 'https://github.com/nvim-mini/mini.icons' },
  { src = 'https://github.com/nvim-mini/mini.tabline' },
  { src = 'https://github.com/stevearc/oil.nvim' },
})

-- Icons first: everything below picks them up through the devicons shim.
require('plugins.icons')

require('plugins.treesitter')
require('plugins.context')
require('plugins.completion')
require('plugins.fzf')
require('plugins.git')
require('plugins.filetree')
require('plugins.oil')
require('plugins.tabline')
