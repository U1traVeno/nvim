-- rust-analyzer. Binary comes from modules/packages/rust.nix.
---@type vim.lsp.Config
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
  settings = {
    ['rust-analyzer'] = {
      check = {
        -- clippy is installed alongside cargo, so use it for diagnostics.
        command = 'clippy',
      },
    },
  },
}
