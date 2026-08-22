-- Editor options. Only settings that differ from Neovim's defaults are listed;
-- Neovim already enables things Vim did not, such as 'incsearch', 'hlsearch',
-- 'wildmenu' and sensible 'backspace'.

local o = vim.o

-- Lines and movement
o.number = true
o.relativenumber = true
o.scrolloff = 8
o.wrap = false

-- Indentation. Individual filetypes override this via ftplugins later.
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true

-- Searching
o.ignorecase = true
o.smartcase = true

-- Persistent undo instead of swap files.
o.swapfile = false
o.undofile = true

-- Keep the sign column always visible so diagnostics do not shift the text.
o.signcolumn = 'yes'

-- Faster CursorHold, used by diagnostics and LSP highlights.
o.updatetime = 250

-- Live substitution preview in a split.
o.inccommand = 'split'

-- Use the system clipboard for yanks. Scheduled so it does not slow startup
-- while the provider is being resolved.
vim.schedule(function()
  o.clipboard = 'unnamedplus'
end)

-- Show whitespace that usually matters.
o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Diagnostics: inline virtual text is off by default in Neovim; turn it on but
-- keep it short, and show the full message in the float bound in keymaps.lua.
vim.diagnostic.config({
  virtual_text = { current_line = true },
  severity_sort = true,
})
