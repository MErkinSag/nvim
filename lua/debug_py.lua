-- lua/debug_py.lua
local dap = require("dap")
local map = vim.keymap.set

-- Prompt for args (space-separated)
local function prompt_args()
  local input = vim.fn.input("Args: ")
  if input == "" then
    return {}
  end
  return vim.split(input, "%s+")
end

dap.configurations.python = dap.configurations.python or {}

table.insert(dap.configurations.python, {
  name = "Python: Launch module (prompt)",
  type = "python",
  request = "launch",
  module = function()
    return vim.fn.input("Module: ")
  end,
  args = prompt_args,
  cwd = function()
    return vim.fn.getcwd()
  end,
  console = "integratedTerminal",
  justMyCode = false,
  subProcess=true,
})

-- Run that config directly (by name, not index)
map("n", "<leader>dm", function()
  for _, config in ipairs(dap.configurations.python) do
    if config.name == "Python: Launch module (prompt)" then
      dap.run(config)
      return
    end
  end
  vim.notify("Python debug config not found", vim.log.levels.ERROR)
end, { desc = "Debug python module (prompt)" })

-- Core DAP controls
map("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Breakpoint" })
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional breakpoint" })
map("n", "<leader>dc", function() dap.continue() end, { desc = "Continue" })
map("n", "<leader>do", function() dap.step_over() end, { desc = "Step over" })
map("n", "<leader>di", function() dap.step_into() end, { desc = "Step into" })
map("n", "<leader>dO", function() dap.step_out() end, { desc = "Step out" })
map("n", "<leader>dq", function() dap.terminate() end, { desc = "Quit debug" })
