-- blink.cmp
--
-- The fuzzy matcher is a Rust library. Because the plugin is tracked by semver
-- tag in plugins/init.lua, the prebuilt binary is downloaded automatically and
-- no cargo build step is needed. 'prefer_rust_with_warning' still falls back to
-- the Lua matcher and says so, rather than silently breaking completion.

require('blink.cmp').setup({
  -- 'default' keeps insert-mode keys untouched:
  --   <C-space> open menu   <C-n>/<C-p> select   <C-y> accept   <C-e> cancel
  keymap = { preset = 'default' },

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
