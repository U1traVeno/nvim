-- Entry point.
--
-- Deliberately small and plugin-free for now. Neovim 0.12 ships a plugin
-- manager (vim.pack), LSP client configuration (vim.lsp.config/enable) and
-- default LSP keymaps, so none of the usual bootstrap code is needed.
--
-- Add plugins later with, for example:
--   vim.pack.add({ { src = 'https://github.com/nvim-treesitter/nvim-treesitter' } })
-- Plugins land in ~/.local/share/nvim/site/pack/core/opt and are recorded in
-- nvim-pack-lock.json in this directory, which is meant to be committed.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('options')
require('keymaps')

-- Language servers. Binaries come from Home Manager and are already on PATH,
-- so there is no Mason-style installer here. Each name below resolves to
-- lsp/<name>.lua in this directory.
vim.lsp.enable({ 'gopls', 'rust_analyzer', 'ty' })
