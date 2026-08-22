-- treesitter-context pins the enclosing function, class or block to the top of
-- the window while scrolling through a long body.
--
-- It reads Neovim's built-in treesitter, so it needs no dependency on the
-- nvim-treesitter plugin beyond the parsers that are already installed.

require('treesitter-context').setup({
  -- One line of context per level is usually enough; more of the window goes
  -- to actual code.
  max_lines = 3,
  multiline_threshold = 1,
})

vim.keymap.set('n', '<leader>cc', function()
  require('treesitter-context').toggle()
end, { desc = 'Toggle sticky context' })
