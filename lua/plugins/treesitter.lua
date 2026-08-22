-- Neovim bundles parsers only for c, lua, markdown, query, vim and vimdoc.
local parsers = {
  'bash',
  'go',
  'gomod',
  'gosum',
  'gowork',
  'json',
  'lua',
  'python',
  'rust',
  'toml',
  'yaml',
}

local ts = require('nvim-treesitter')

-- install() hits the network, so only ask for what is actually missing.
local installed = ts.get_installed()
local missing = vim.tbl_filter(function(lang)
  return not vim.tbl_contains(installed, lang)
end, parsers)

if #missing > 0 then
  ts.install(missing)
end

-- The main branch enables nothing by itself; highlighting is opt-in per
-- buffer. pcall covers filetypes with no parser installed.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Start treesitter highlighting when a parser exists',
  callback = function(event)
    pcall(vim.treesitter.start, event.buf)
  end,
})
