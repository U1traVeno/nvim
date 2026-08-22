-- blink.cmp
--
-- The fuzzy matcher is a Rust library. Because the plugin is tracked by semver
-- tag in plugins/init.lua, the prebuilt binary is downloaded automatically and
-- no cargo build step is needed. 'prefer_rust_with_warning' still falls back to
-- the Lua matcher and says so, rather than silently breaking completion.

require('blink.cmp').setup({
  -- 'default' keeps insert-mode keys untouched:
  --   <C-n>/<C-p> select   <C-y> accept   <C-e> cancel
  --   <C-b>/<C-f> scroll docs   <Tab>/<S-Tab> jump between snippet slots
  --
  -- The preset opens the menu with <C-space>, which never reaches Neovim here
  -- because tmux claims C-Space as its prefix. Moved to <C-CR>, which the
  -- terminal can encode distinctly from <CR> thanks to tmux's
  -- `extended-keys on` with the csi-u format.
  keymap = {
    preset = 'default',
    ['<C-space>'] = false,
    ['<C-CR>'] = { 'show', 'show_documentation', 'hide_documentation' },
  },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
  },

  signature = {
    enabled = true,
  },

  fuzzy = {
    implementation = 'prefer_rust_with_warning',
  },
})

-- Advertise blink's completion capabilities to every language server. The
-- servers are configured natively in lsp/, not through lspconfig, so this is
-- applied with the '*' wildcard config.
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})
