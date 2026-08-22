-- gitsigns brings git state into the buffer itself. lazygit is still the tool
-- for staging and committing; this is for the questions you ask while reading
-- code: what changed here, and who changed this line.

require('gitsigns').setup({
  -- Off by default because a virtual comment on every line is a lot; toggled
  -- with <leader>gb below.
  current_line_blame = false,
  current_line_blame_opts = {
    delay = 300,
    virt_text_pos = 'eol',
  },

  on_attach = function(bufnr)
    local gs = require('gitsigns')

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Hunk navigation follows the [x / ]x convention Neovim already uses for
    -- diagnostics and buffers.
    map('n', ']h', function() gs.nav_hunk('next') end, 'Next hunk')
    map('n', '[h', function() gs.nav_hunk('prev') end, 'Previous hunk')

    map('n', '<leader>gp', gs.preview_hunk, 'Preview hunk')
    map('n', '<leader>gb', gs.toggle_current_line_blame, 'Toggle line blame')
    map('n', '<leader>gB', function() gs.blame_line({ full = true }) end, 'Blame line (full)')
    map('n', '<leader>gd', gs.diffthis, 'Diff against index')
    map('n', '<leader>gr', gs.reset_hunk, 'Reset hunk')
  end,
})
