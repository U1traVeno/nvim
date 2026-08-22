-- oil.nvim
--
-- Kept alongside nvim-tree because the two are for different jobs: the tree is
-- for browsing an unfamiliar layout, oil is for editing the filesystem as text
-- (rename, delete and create by editing lines, then :w).
--
-- Bound to `-`, the vim-vinegar convention, which leaves <leader>e for the
-- tree. oil also stays the handler for `nvim some/dir`.

require('oil').setup({
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Edit parent directory' })
