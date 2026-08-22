-- ruff, Astral's Python linter and formatter. Binary comes from
-- modules/packages/python.nix.
--
-- Runs alongside ty on Python buffers: ty is a type checker and does not
-- implement formatting, so ruff supplies formatting and lint diagnostics while
-- ty supplies types.
---@type vim.lsp.Config
return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'ruff.toml', '.ruff.toml', 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' },
}
