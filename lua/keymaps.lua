-- Keymaps.
--
-- Neovim 0.12 already binds the common LSP actions, so they are not repeated
-- here:
--   K    hover              grn  rename            gra  code action
--   grr  references         gri  implementation    grt  type definition
--   gO   document symbol    grx  run code lens
-- and for diagnostics:
--   [d / ]d  previous / next        <C-W>d  show diagnostic under cursor

local map = vim.keymap.set

-- Clear search highlight.
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Leave terminal mode without reaching for <C-\><C-n>.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Definition is the one common LSP action Neovim does not map by default.
-- It only makes sense once a server is attached, so bind it per buffer.
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'Buffer-local LSP keymaps',
  callback = function(event)
    map('n', 'gd', vim.lsp.buf.definition, {
      buffer = event.buf,
      desc = 'vim.lsp.buf.definition()',
    })
  end,
})

-- Compile and run the current file or project.
map('n', '<leader>r', require('run').run, { desc = 'Run current file or project' })

-- Briefly highlight yanked text so the region is obvious.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  callback = function()
    vim.hl.on_yank()
  end,
})
