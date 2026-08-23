-- mini.statusline.
--
-- Its default layout already covers mode, git branch, diff counts,
-- diagnostics, attached LSP clients, filename, file info, search count and
-- position, with the mode section colour-coded.
--
-- What it replaces loses one thing from Neovim's default statusline: the LSP
-- progress spinner from vim.ui.progress_status(). Added back below so a slow
-- rust-analyzer index is still visible.

require('mini.statusline').setup({
  content = {
    active = function()
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local git = MiniStatusline.section_git({ trunc_width = 40 })
      local diff = MiniStatusline.section_diff({ trunc_width = 75 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
      local location = MiniStatusline.section_location({ trunc_width = 75 })
      local search = MiniStatusline.section_searchcount({ trunc_width = 75 })

      -- Neovim's own progress reporting, e.g. rust-analyzer indexing.
      local progress = package.loaded['vim.ui'] and vim.ui.progress_status() or ''

      return MiniStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=',
        { hl = 'MiniStatuslineDevinfo', strings = { progress } },
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl, strings = { search, location } },
      })
    end,
  },
})
