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
  -- because tmux claims C-Space as its prefix.
  --
  -- <C-CR> was tried first and does not work: Ctrl-V Ctrl-Enter shows ^M, so
  -- the terminal collapses it to a plain carriage return and the mapping never
  -- fires. <C-l> needs no extended-key negotiation and Neovim leaves it unused
  -- in insert mode.
  -- The preset chains show, show_documentation and hide_documentation onto one
  -- key and stops at the first command that runs. The menu auto-triggers while
  -- typing, so `show` never got its turn and the key acted as a docs toggle.
  --
  -- There is no separate documentation key on purpose: docs already appear on
  -- their own, <C-b> and <C-f> scroll them, and <C-l> takes the menu and its
  -- docs down together.
  keymap = {
    preset = 'default',
    ['<C-space>'] = false,
    -- hide first, so the pair acts as a real toggle.
    ['<C-l>'] = { 'hide', 'show' },
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
