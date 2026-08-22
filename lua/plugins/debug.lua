-- nvim-dap. Neovim has no built-in debug adapter client, so this is the one
-- piece that cannot come from core.
--
-- Only the core plugin is installed. nvim-dap-ui would pull in nvim-nio as
-- well; nvim-dap already ships a REPL and hover widgets, which is enough to
-- start with.
--
-- Adapters are external programs, and both are already on this machine:
--   Go    dlv, from modules/packages/golang.nix
--   Rust  lldb-dap, from the Xcode Command Line Tools
-- Python would need debugpy, which is not installed, so it is left out.

local dap = require('dap')

-- ------------------------------------------------------------------ adapters

dap.adapters.delve = function(callback, config)
  callback({
    type = 'server',
    port = '${port}',
    executable = {
      command = 'dlv',
      args = { 'dap', '-l', '127.0.0.1:${port}' },
      detach = vim.fn.has('win32') == 0,
      cwd = config.cwd,
    },
  })
end

-- Not on PATH, and deliberately not added to it: this is Xcode's copy, tied to
-- the system toolchain rather than to Home Manager.
local lldb_dap = '/Library/Developer/CommandLineTools/usr/bin/lldb-dap'

if vim.uv.fs_stat(lldb_dap) then
  dap.adapters.lldb = {
    type = 'executable',
    command = lldb_dap,
    name = 'lldb',
  }
end

-- ------------------------------------------------------------ configurations

dap.configurations.go = {
  {
    type = 'delve',
    name = 'Debug this package',
    request = 'launch',
    program = '${fileDirname}',
  },
  {
    type = 'delve',
    name = 'Debug this test',
    request = 'launch',
    mode = 'test',
    program = '${fileDirname}',
  },
}

-- lldb debugs a binary, not a source file, so the crate has to be built first.
local function cargo_binary()
  local root = vim.fs.root(0, { 'Cargo.toml' })
  if not root then
    return nil, 'Not inside a Cargo project'
  end

  local build = vim.system({ 'cargo', 'build' }, { cwd = root, text = true }):wait()
  if build.code ~= 0 then
    return nil, 'cargo build failed:\n' .. (build.stderr or '')
  end

  local name = vim.fs.basename(root)
  local path = vim.fs.joinpath(root, 'target', 'debug', name)
  if not vim.uv.fs_stat(path) then
    return nil, 'No debug binary at ' .. path
  end
  return path
end

dap.configurations.rust = {
  {
    type = 'lldb',
    name = 'Debug this crate',
    request = 'launch',
    program = function()
      local path, err = cargo_binary()
      if not path then
        error(err)
      end
      return path
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

-- ---------------------------------------------------------------- appearance

vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn' })
vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticOk', linehl = 'Visual' })

-- ------------------------------------------------------------------- keymaps

local map = vim.keymap.set

map('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
map('n', '<leader>dB', function()
  vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(cond)
    if cond and cond ~= '' then
      dap.set_breakpoint(cond)
    end
  end)
end, { desc = 'Conditional breakpoint' })

map('n', '<leader>dc', dap.continue, { desc = 'Continue / start' })
map('n', '<leader>di', dap.step_into, { desc = 'Step into' })
map('n', '<leader>do', dap.step_over, { desc = 'Step over' })
map('n', '<leader>dO', dap.step_out, { desc = 'Step out' })
map('n', '<leader>dr', dap.repl.toggle, { desc = 'Toggle REPL' })
map('n', '<leader>dt', dap.terminate, { desc = 'Terminate' })

-- Inspect whatever is under the cursor while stopped.
map({ 'n', 'v' }, '<leader>dh', function()
  require('dap.ui.widgets').hover()
end, { desc = 'Inspect value' })

map('n', '<leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end, { desc = 'Scopes' })
