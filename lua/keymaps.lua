-- Keymaps.
--
-- Neovim 0.12 already binds the common LSP actions, so they are not repeated
-- here:
--   K    hover              grn  rename            gra  code action
--   grr  references         gri  implementation    grt  type definition
--   gO   document symbol    grx  run code lens
-- and for diagnostics:
--   [d / ]d  previous / next        <C-W>d  show diagnostic under cursor

local map = vim.keymap.set

-- Clear search highlight.
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Leave terminal mode without reaching for <C-\><C-n>.
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Definition is the one common LSP action Neovim does not map by default.
-- It only makes sense once a server is attached, so bind it per buffer.
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'Buffer-local LSP keymaps',
  callback = function(event)
    map('n', 'gd', vim.lsp.buf.definition, {
      buffer = event.buf,
      desc = 'vim.lsp.buf.definition()',
    })

    -- Formatting comes from the language servers, so there is no separate
    -- formatter plugin: gopls and rust-analyzer format their own languages,
    -- and ruff formats Python because ty only does type checking.
    map({ 'n', 'v' }, '<leader>cf', function()
      vim.lsp.buf.format({ async = true })
    end, {
      buffer = event.buf,
      desc = 'Format buffer',
    })

    -- Inlay hints answer "what type is this" without moving the cursor or
    -- opening a float. They are noisy on dense lines, so they are also on a
    -- toggle.
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/inlayHint') then
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })

      map('n', '<leader>ch', function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
      end, {
        buffer = event.buf,
        desc = 'Toggle inlay hints',
      })
    end
  end,
})

-- Compile and run the current file or project.
map('n', '<leader>r', require('run').run, { desc = 'Run current file or project' })

-- Briefly highlight yanked text so the region is obvious.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  callback = function()
    vim.hl.on_yank()
  end,
})
