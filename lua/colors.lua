-- Highlight overrides.
--
-- No colorscheme is installed, so this rides on Neovim's default. In that
-- default every keyword group resolves to the same near-white as normal text,
-- which flattens the syntax out. Give keywords the purple that most IDE themes
-- use for them.
--
-- Reapplied on ColorScheme because loading a scheme clears non-default
-- highlights, so this survives installing a real theme later.

local keyword = '#bb9af7'

local function apply()
  -- Everything else hangs off @keyword, so the colour is set in one place.
  vim.api.nvim_set_hl(0, '@keyword', { fg = keyword })

  for _, group in ipairs({
    '@keyword.conditional', -- match, if, else
    '@keyword.repeat', -- loop, while, for, continue, break
    '@keyword.return',
    '@keyword.function', -- fn
    '@keyword.operator', -- as, in
    '@keyword.exception',
    '@keyword.import', -- use, mod
    '@keyword.modifier', -- pub, mut, const
    '@keyword.coroutine', -- async, await
    '@keyword.type', -- struct, enum, impl
  }) do
    vim.api.nvim_set_hl(0, group, { link = '@keyword' })
  end
end

apply()

vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'Keep keyword colours after a scheme loads',
  callback = apply,
})
