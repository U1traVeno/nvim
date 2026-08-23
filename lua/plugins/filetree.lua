-- nvim-tree
--
-- A toggled sidebar tree, not a permanent one: <leader>e opens it, <leader>e
-- closes it again.
--
-- Chosen over neo-tree because vim.pack does no dependency resolution and
-- neo-tree would mean declaring plenary and nui by hand as well. nvim-tree has
-- no required dependencies.
--
-- Directory hijacking is left to oil, so `nvim some/dir` still opens the
-- editable directory buffer and the tree stays purely a sidebar.

-- Git status is rendered the way lazygit does it, so the two tools agree.
-- lazygit's formatFileStatus prints the git porcelain XY code and colours the
-- index column green, the worktree column with unstagedChangesColor (red by
-- default), and an untracked '?' red in both columns.
local git_glyphs = {
  staged = 'M', -- index column: a change that is ready to commit
  renamed = 'R',
  untracked = '?',
  unstaged = 'M', -- worktree column: a change that is not staged yet
  deleted = 'D',
  unmerged = 'U',
  ignored = '◌',
}

-- Buffer-local keys inside the tree. Defaults are kept, then the navigation
-- keys are pointed at the vim directions: l descends, h ascends.
--
-- <CR> is left as the only toggle. <Space> stays free because it is the leader
-- key, and nvim-tree binds with nowait, so mapping it here would kill every
-- leader sequence while the cursor is in the tree.
local function on_attach(bufnr)
  local api = require('nvim-tree.api')

  api.config.mappings.default_on_attach(bufnr)

  local function opts(desc)
    return {
      desc = 'nvim-tree: ' .. desc,
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true,
    }
  end

  vim.keymap.set('n', 'l', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', 'h', api.tree.change_root_to_parent, opts('Up'))
end

require('nvim-tree').setup({
  on_attach = on_attach,
  hijack_directories = {
    enable = false,
  },
  view = {
    width = 36,
  },
  diagnostics = {
    enable = true,
    -- Mark the containing folders too, so a problem is visible without
    -- expanding the tree to find it.
    show_on_dirs = true,
    show_on_open_dirs = true,
    -- Hints are routine in Rust and Go and would end up colouring most of the
    -- tree. Only warnings and errors mean "look here".
    severity = {
      min = vim.diagnostic.severity.WARN,
      max = vim.diagnostic.severity.ERROR,
    },
  },
  renderer = {
    group_empty = true,
    -- Colour the name itself, not just add an icon.
    highlight_diagnostics = 'name',
    -- Default is ":~:s?$?/..?", which spells out the whole path from $HOME and
    -- overflows the sidebar in a nested checkout. Show only the final
    -- component, so `nvim .` in derivon-core is labelled "derivon-core".
    root_folder_label = ':t',
    icons = {
      glyphs = {
        git = git_glyphs,
      },
    },
  },
  filters = {
    -- Entries are vim regexes, tested against both the path relative to the
    -- cwd and the basename. See the notes at the bottom of this file.
    custom = {
      '^\\.git$',
      '^\\.DS_Store$',
    },
  },
  actions = {
    open_file = {
      -- Browsing usually ends in opening a file, so get the sidebar out of
      -- the way instead of leaving a narrow split behind.
      quit_on_open = true,
    },
  },
})

-- nvim-tree links its git highlights to generic syntax groups (Statement,
-- PreProc, Constant), which makes every state look alike. Repoint them at the
-- terminal's own red and green so the colours match lazygit running in the
-- same terminal. Reapplied on ColorScheme because loading a scheme clears
-- non-default highlights.
-- nvim-tree points the diagnostic name highlights at DiagnosticUnderline*,
-- which carry underline plus a `sp` colour and no `fg`, so a bad file gets
-- underlined rather than recoloured. Point them at the groups that actually
-- set a foreground.
local function apply_diagnostic_highlights()
  local groups = {
    NvimTreeDiagnosticErrorFileHL = 'DiagnosticError',
    NvimTreeDiagnosticWarnFileHL = 'DiagnosticWarn',
    NvimTreeDiagnosticInfoFileHL = 'DiagnosticInfo',
    NvimTreeDiagnosticHintFileHL = 'DiagnosticHint',
    NvimTreeDiagnosticErrorFolderHL = 'DiagnosticError',
    NvimTreeDiagnosticWarnFolderHL = 'DiagnosticWarn',
    NvimTreeDiagnosticInfoFolderHL = 'DiagnosticInfo',
    NvimTreeDiagnosticHintFolderHL = 'DiagnosticHint',
  }

  for group, target in pairs(groups) do
    vim.api.nvim_set_hl(0, group, { link = target })
  end
end

local function apply_git_highlights()
  local red = vim.g.terminal_color_1 or '#e06c75'
  local green = vim.g.terminal_color_2 or '#98c379'

  local groups = {
    NvimTreeGitStagedIcon = { fg = green, ctermfg = 2 },
    NvimTreeGitRenamedIcon = { fg = green, ctermfg = 2 },
    NvimTreeGitDirtyIcon = { fg = red, ctermfg = 1 },
    NvimTreeGitNewIcon = { fg = red, ctermfg = 1 },
    NvimTreeGitDeletedIcon = { fg = red, ctermfg = 1 },
    NvimTreeGitMergeIcon = { fg = red, ctermfg = 1 },
    NvimTreeGitIgnoredIcon = { link = 'Comment' },
  }

  for group, opts in pairs(groups) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

apply_git_highlights()
apply_diagnostic_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Keep nvim-tree git and diagnostic colours after a scheme loads',
  callback = function()
    apply_git_highlights()
    apply_diagnostic_highlights()
  end,
})

vim.keymap.set('n', '<leader>e', function()
  require('nvim-tree.api').tree.toggle({ find_file = true })
end, { desc = 'Toggle file tree' })

-- Hiding entries
-- --------------
-- filters.git_ignored  (default true)  hide anything .gitignore covers
-- filters.dotfiles     (default false) hide every dotfile at once
-- filters.custom       vim regexes, matched against the cwd-relative path and
--                      the basename; "*.ext" is also accepted as a suffix rule
-- filters.exclude      lua patterns that force an entry to stay visible even
--                      when another filter would hide it
--
-- Toggle at runtime without editing this file:
--   I  toggle filters.git_ignored
--   H  toggle filters.dotfiles
--   U  toggle filters.custom
