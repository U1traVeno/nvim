-- mini.icons is the single icon provider for every plugin here.
--
-- nvim-tree, oil and fzf-lua all look for nvim-web-devicons. Mocking its
-- interface means one zero-dependency plugin serves all of them instead of
-- pulling in a second icon plugin.
--
-- Icons need a Nerd Font whose glyphs are one cell wide. The plain
-- "JetBrainsMono Nerd Font" family draws them at 1.5 cells, which terminals
-- clip on the right; the "Mono" family is the one to select in the terminal.

require('mini.icons').setup()

MiniIcons.mock_nvim_web_devicons()
