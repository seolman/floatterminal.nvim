local state = {
  floating = {
    buf = -1,
    win = -1,
  }
}

-- vim.api.nvim_win_get_width(0)
local function is_percentage(number)
  return number > 0 and number < 1
end

local function create_floating_window(opts)
  opts = opts or {}

  local width
  if opts.width then
    if is_percentage(opts.width) then
      width = math.floor(vim.api.nvim_win_get_width(0) * opts.width)
    else
      width = opts.width
    end
  else
      width = math.floor(vim.api.nvim_win_get_width(0) * 0.8)
  end

  local height
  if opts.height then
    if is_percentage(opts.height) then
      height = math.floor(vim.api.nvim_win_get_height(0) * opts.height)
    else
      height = opts.height
    end
  else
      height = math.floor(vim.api.nvim_win_get_height(0) * 0.8)
  end

  local col = math.floor((vim.api.nvim_win_get_width(0) - width) / 2) - 1
  local row = math.floor((vim.api.nvim_win_get_height(0) - height) / 2) - 1

  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "single",
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

local function toggle_terminal()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= "terminal" then
      vim.cmd.terminal()
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

vim.api.nvim_create_user_command("FloatTerminal", toggle_terminal, {})

vim.keymap.set("n", "<leader>t", "<cmd>FloatTerminal<cr>")
