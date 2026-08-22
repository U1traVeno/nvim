-- ty, Astral's Python type checker. Binary comes from
-- modules/packages/python.nix.
--
-- ty is a type checker, not a full language server: it provides diagnostics,
-- hover and go-to-definition, but no formatting. ruff is installed too and can
-- be added as a second client later for lint and format.
---@type vim.lsp.Config
return {
  cmd = { 'ty', 'server' },
  filetypes = { 'python' },
  root_markers = { 'ty.toml', 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' },
}
