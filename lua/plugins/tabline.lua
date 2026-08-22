-- mini.tabline shows the listed buffers along the top, so it is visible that
-- closing one file does not mean closing the editor.
--
-- These are buffers, not Vim tabpages. Vim tabpages are window layouts, not
-- files, so a "tab per file" workflow is really a buffer workflow.
--
-- Navigation needs no mappings: Neovim already binds [b and ]b to :bprevious
-- and :bnext, plus [B and ]B for first and last.

require('mini.tabline').setup()

-- The habit this exists for: :q closes the window, and closing the last window
-- quits Neovim. <leader>q closes just the file and leaves the editor running.
vim.keymap.set('n', '<leader>q', '<cmd>bdelete<CR>', { desc = 'Close buffer' })
