-- Plugins, managed by Neovim's built-in vim.pack.
--
-- Payloads live in ~/.local/share/nvim/site/pack/core/opt; the resolved
-- revisions are written to nvim-pack-lock.json in this directory, which is
-- committed. Update everything with :lua vim.pack.update().
--
-- During init.lua sourcing vim.pack.add defaults to load = false, which
-- behaves like :packadd! — the plugin is on 'runtimepath' immediately, so
-- require() works here, while its plugin/ files are sourced at the normal
-- point in startup.

vim.pack.add({
  -- master is frozen and does not support Neovim 0.12, so pin main explicitly.
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/stevearc/oil.nvim' },
})

-- ---------------------------------------------------------------- treesitter

-- Neovim bundles parsers only for c, lua, markdown, query, vim and vimdoc.
local parsers = {
  'bash',
  'go',
  'gomod',
  'gosum',
  'gowork',
  'json',
  'lua',
  'python',
  'rust',
  'toml',
  'yaml',
}

local ts = require('nvim-treesitter')

-- install() hits the network, so only ask for what is actually missing.
local installed = ts.get_installed()
local missing = vim.tbl_filter(function(lang)
  return not vim.tbl_contains(installed, lang)
end, parsers)

if #missing > 0 then
  ts.install(missing)
end

-- The rewrite does not enable anything by itself; highlighting is opt-in per
-- buffer. pcall covers filetypes with no parser installed.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Start treesitter highlighting when a parser exists',
  callback = function(event)
    pcall(vim.treesitter.start, event.buf)
  end,
})

-- ---------------------------------------------------------------------- oil

require('oil').setup({
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set('n', '<leader>e', '<cmd>Oil<CR>', { desc = 'Open parent directory' })
