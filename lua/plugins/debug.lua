-- nvim-dap plus the two companions almost everyone pairs it with.
--
-- Neovim has no built-in debug adapter client, so unlike LSP, formatting and
-- completion this cannot come from core.
--
--   nvim-dap                  the client
--   nvim-dap-ui               scopes, stacks, breakpoints, watches, console
--   nvim-nio                  required by nvim-dap-ui; vim.pack does not
--                             resolve dependencies, so it is declared by hand
--   nvim-dap-virtual-text     values shown inline next to the code
--
-- Adapters are external programs, and both are already on this machine:
--   Go    dlv, from modules/packages/golang.nix
--   Rust  lldb-dap, from the Xcode Command Line Tools
-- Python would need debugpy, which is not installed.

local dap = require('dap')
local dapui = require('dapui')

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

-- ------------------------------------------------------------------------ ui

dapui.setup()

require('nvim-dap-virtual-text').setup({
  -- The default on Neovim 0.10+ is 'inline', which splices the value between
  -- the identifier and the rest of the statement and reads as
  -- `total = 15 := 0`. End of line keeps the source intact; the Scopes panel
  -- is there when per-variable precision is wanted.
  virt_text_pos = 'eol',
})

-- Open the panels when a session starts and close them when it ends, so
-- "is it running" is answered by the screen rather than by guessing.
dap.listeners.after.event_initialized['dapui'] = function()
  dapui.open()
end
dap.listeners.before.event_terminated['dapui'] = function()
  dapui.close()
end
dap.listeners.before.event_exited['dapui'] = function()
  dapui.close()
end

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
map('n', '<leader>dt', dap.terminate, { desc = 'Terminate' })

-- Panels. dapui.eval opens a floating window; pressing the key again focuses
-- it, and q closes it, which the bare dap.ui.widgets hover did not offer.
map('n', '<leader>du', dapui.toggle, { desc = 'Toggle debug panels' })
map({ 'n', 'v' }, '<leader>dh', function()
  dapui.eval(nil, { enter = true })
end, { desc = 'Inspect value' })
