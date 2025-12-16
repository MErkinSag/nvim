vim.notify("Loaded init.lua from " .. vim.fn.stdpath("config"))

vim.opt.number = true          -- :set nu
vim.opt.relativenumber = true  -- :set rnu


vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local map = vim.keymap.set
      local builtin = require("telescope.builtin")

      map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
    end,
  },

  -- File explorer (tree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
      })

      vim.keymap.set(
        "n",
        "<leader>e",
        "<cmd>NvimTreeToggle<cr>",
        { desc = "Explorer" }
      )
    end,
  },

  -- DAP core
  { "mfussenegger/nvim-dap" },

  -- Python DAP helper
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-python").setup(vim.fn.exepath("python3"))
      require("debug_py") -- load our custom debug config + keymaps
    end,
  },


  -- Neoscroll
  {
    "karb94/neoscroll.nvim",
    opts = {
	duration_multiplier = 0.2,  -- faster (default 1.0)
	easing = "quadratic",
    },
  },
})

local function copy_path_line_cols()
  -- Absolute path (use "%:." for relative to cwd, "%:~" for ~)
  local path = vim.fn.expand("%:p")

  -- Visual selection endpoints:
  -- "v" = where visual started, "." = current cursor
  local a = vim.fn.getpos("v")  -- {bufnum, lnum, col, off}
  local b = vim.fn.getpos(".")
  local l1, c1 = a[2], a[3]
  local l2, c2 = b[2], b[3]

  -- Normalize ordering (so start <= end)
  if (l2 < l1) or (l2 == l1 and c2 < c1) then
    l1, l2 = l2, l1
    c1, c2 = c2, c1
  end

  -- Format however you like
  local text = string.format("%s:%d:%d-%d:%d", path, l1, c1, l2, c2)

  -- Copy to clipboard + unnamed
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)

  -- Optional message
  vim.notify("Copied: " .. text)
end

vim.keymap.set("v", "<leader>cp", copy_path_line_cols, { silent = true, desc = "Copy path + selection range" })
