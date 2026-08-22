-- fzf-lua
--
-- Chosen over telescope because it needs no plenary and drives the fzf binary
-- that Home Manager already installs, so there is one less thing to keep in
-- sync.

local fzf = require('fzf-lua')

fzf.setup({
  'default',
  winopts = {
    height = 0.85,
    width = 0.85,
    preview = { layout = 'vertical' },
  },
})

local map = vim.keymap.set

map('n', '<leader>ff', fzf.files, { desc = 'Find files' })
map('n', '<leader>fg', fzf.live_grep, { desc = 'Grep in project' })
map('n', '<leader>fb', fzf.buffers, { desc = 'Find buffers' })
map('n', '<leader>fh', fzf.helptags, { desc = 'Find help tags' })
map('n', '<leader>fd', fzf.diagnostics_workspace, { desc = 'Find diagnostics' })
map('n', '<leader>fr', fzf.resume, { desc = 'Resume last picker' })

-- Jump to any symbol in the project by name. gO only covers the current file.
map('n', '<leader>fs', fzf.lsp_live_workspace_symbols, { desc = 'Find symbol in project' })

-- Grep for the word under the cursor.
map('n', '<leader>f*', fzf.grep_cword, { desc = 'Grep word under cursor' })

-- Searchable list of every mapping, mirroring the g? that nvim-tree and oil
-- already provide for their own buffers. Those are buffer-local and still win
-- inside their windows, so this only fills in everywhere else.
--
-- g? is Vim's rot13 operator, which is not worth keeping.
map('n', 'g?', fzf.keymaps, { desc = 'Find keymaps' })
