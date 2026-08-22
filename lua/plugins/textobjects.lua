-- mini.ai extends i/a text objects.
--
-- The built-in specs are used rather than the treesitter ones: nvim-treesitter
-- on the main branch ships highlights, indents, folds, injections, locals and
-- context queries, but no textobjects.scm, so @function.outer and friends do
-- not resolve. Adding nvim-treesitter-textobjects would be the way to get
-- definition-level objects later.
--
-- What this adds on top of Vim's own iw/i"/i( set:
--   ia / aa   argument, the big one: cia changes one argument
--   if / af   function *call* (not a definition)
--   ib / ab   the nearest balanced bracket, any of ( [ {
--   iq / aq   the nearest quote, any of " ' `
--   i? / a?   prompt for arbitrary delimiters
-- plus n and l modifiers, so in( targets the next parentheses and il( the
-- previous ones.

require('mini.ai').setup()
