-- mini.surround adds, deletes and replaces surrounding characters.
--
-- It takes s as its prefix, which shadows the built-in s ("delete one
-- character and insert", identical to cl). S, cl and cc are untouched, so
-- nothing is actually lost.
--
-- Best at inline pairs: quotes, brackets, tags. Wrapping a multi-line block in
-- something like `loop { ... }` is still faster with O and o plus a formatter
-- pass.

require('mini.surround').setup()
