-- Compile and run the current buffer.
--
-- Project aware: inside a Go module it runs the package, inside a Cargo
-- project it runs the crate, and otherwise it falls back to running the single
-- file on its own. Output goes to a terminal split that is reused between
-- runs, so repeated <leader>r does not stack windows.

local M = {}

local HEIGHT = 15

-- Buffer and window of the last run, reused when still valid.
local term_buf, term_win

--- @param file string
--- @param markers string[]
--- @return string? root
local function root_of(file, markers)
  return vim.fs.root(file, markers)
end

--- Each runner returns the shell command and the directory to run it in.
--- @type table<string, fun(file: string): string, string>
local runners = {
  go = function(file)
    local dir = vim.fs.dirname(file)
    if root_of(file, { 'go.work', 'go.mod' }) then
      -- Run the whole package so sibling files are compiled in.
      return 'go run .', dir
    end
    return 'go run ' .. vim.fn.shellescape(file), dir
  end,

  python = function(file)
    return 'python3 ' .. vim.fn.shellescape(file), vim.fs.dirname(file)
  end,

  rust = function(file)
    local root = root_of(file, { 'Cargo.toml' })
    if root then
      return 'cargo run', root
    end
    -- A loose .rs file still needs an explicit output path from rustc.
    local out = vim.fn.tempname()
    return ('rustc -o %s %s && %s'):format(
      vim.fn.shellescape(out),
      vim.fn.shellescape(file),
      vim.fn.shellescape(out)
    ), vim.fs.dirname(file)
  end,
}

--- Open, or reuse, the split that run output goes to.
local function open_output_window()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_set_current_win(term_win)
  else
    vim.cmd(('botright %dsplit'):format(HEIGHT))
    term_win = vim.api.nvim_get_current_win()
  end

  -- Replace the previous run's buffer rather than leaving it behind.
  local previous = term_buf
  vim.cmd('enew')
  term_buf = vim.api.nvim_get_current_buf()
  if previous and vim.api.nvim_buf_is_valid(previous) then
    vim.api.nvim_buf_delete(previous, { force = true })
  end
end

function M.run()
  local ft = vim.bo.filetype
  local runner = runners[ft]
  if not runner then
    vim.notify(("No runner configured for filetype '%s'"):format(ft), vim.log.levels.WARN)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    vim.notify('Buffer is not backed by a file', vim.log.levels.WARN)
    return
  end

  if vim.bo.modified then
    vim.cmd('silent write')
  end

  local cmd, cwd = runner(file)
  open_output_window()

  vim.fn.jobstart(cmd, {
    term = true,
    cwd = cwd,
    on_exit = function(_, code)
      if vim.api.nvim_buf_is_valid(term_buf) then
        vim.bo[term_buf].modifiable = false
      end
      if code ~= 0 then
        vim.notify(('Exited with %d'):format(code), vim.log.levels.WARN)
      end
    end,
  })

  -- Close the output with q, like a help window.
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = term_buf, desc = 'Close run output' })
end

return M
