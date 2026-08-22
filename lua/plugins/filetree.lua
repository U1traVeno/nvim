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

require('nvim-tree').setup({
  hijack_directories = {
    enable = false,
  },
  view = {
    width = 36,
  },
  renderer = {
    group_empty = true,
    -- Default is ":~:s?$?/..?", which spells out the whole path from $HOME and
    -- overflows the sidebar in a nested checkout. Show only the final
    -- component, so `nvim .` in derivon-core is labelled "derivon-core".
    root_folder_label = ':t',
  },
  actions = {
    open_file = {
      -- Browsing usually ends in opening a file, so get the sidebar out of
      -- the way instead of leaving a narrow split behind.
      quit_on_open = true,
    },
  },
})

vim.keymap.set('n', '<leader>e', function()
  require('nvim-tree.api').tree.toggle({ find_file = true })
end, { desc = 'Toggle file tree' })
