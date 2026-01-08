vim.notify("Loaded init.lua from " .. vim.fn.stdpath("config"))


vim.opt.number = true          -- :set nu
vim.opt.relativenumber = true  -- :set rnu

vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.opt.guicursor = "n-v-i-c:block"

vim.g.mapleader = " "

-- Remap Ctrl+E to scroll down 7 lines in normal mode
vim.keymap.set("n", "<C-e>", "7<C-e>", { noremap = true, silent = true })

-- Remap Ctrl+Y to scroll up 7 lines in normal mode
vim.keymap.set("n", "<C-y>", "7<C-y>", { noremap = true, silent = true })

-- DAP
vim.keymap.set("n", "dv", "<cmd>DapViewOpen<cr>", { desc = "DAP view open" })

vim.keymap.set("n", "dV", "<cmd>DapViewClose<cr>", { desc = "DAP view close" })


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
      local python_path = vim.g.python_interpreter_path or vim.fn.exepath("python3")
      require("dap-python").setup(python_path)
      require("debug_py") -- load our custom debug config + keymaps
    end,
  },

  -- DAP UI
  {
        "igorlfs/nvim-dap-view",
        ---@module 'dap-view'
        ---@type dapview.Config
        opts = {},
    },
  -- { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},

  -- Neoscroll
  --{
  --  "karb94/neoscroll.nvim",
  --  opts = {
  --      duration_multiplier = 0.2,  -- faster (default 1.0)
  --      easing = "quadratic",
  --  },
  -- },

-- LSP

-- Mason for auto-installing LSP servers
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig", -- still needed for server configs
    },
    opts = {
      ensure_installed = { "basedpyright" },
    },
  },

  -- nvim-lspconfig now just provides server configurations
  -- that vim.lsp.config can use
  { "neovim/nvim-lspconfig" },

  -- Colorscheme
  {
    "zenbones-theme/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    -- you can set set configuration options here
     config = function()
    --     vim.g.zenbones_darken_comments = 45
         vim.cmd.colorscheme('zenbones')
     end
},

-- Context
{	
	'wellle/context.vim',
	opts = {},
}

})


-- Set up keymaps via LspAttach autocmd (runs for any LSP)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    -- map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gr", vim.lsp.buf.references, "References")
    map("n", "gR", function()
          require("telescope.builtin").lsp_references()
        end, "References (Telescope)")
    map("n", "K",  vim.lsp.buf.hover, "Hover")
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
  end,
})

-- Configure and enable pyright using the new API
--

local python_path = vim.g.python_interpreter_path or "/usr/bin/python3"

vim.lsp.config("basedpyright", {
  on_attach = function(client, bufnr)
    client.server_capabilities.semanticTokensProvider = nil
  end,
  settings = {
    python = {
      pythonPath = python_path,
      -- Or for venv:
      -- venvPath = ".",
      -- venv = ".venv",
    },
  },
})

vim.diagnostic.config({
  underline = {
    severity = { min = vim.diagnostic.severity.ERROR }
  },
})

vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show diagnostics" })

vim.lsp.enable("basedpyright")


local function copy_path_line_cols(opts)
  opts = opts or {}

  local path
  if opts.absolute then
    path = vim.fn.expand("%:p")   -- absolute
  else
    path = vim.fn.expand("%:.")   -- relative to cwd
  end

  -- Visual selection endpoints
  local a = vim.fn.getpos("v")
  local b = vim.fn.getpos(".")

  local l1, c1 = a[2], a[3]
  local l2, c2 = b[2], b[3]

  -- Normalize order
  if (l2 < l1) or (l2 == l1 and c2 < c1) then
    l1, l2 = l2, l1
    c1, c2 = c2, c1
  end

  local text = string.format("%s:%d:%d-%d:%d", path, l1, c1, l2, c2)

  -- Yank to clipboard + unnamed
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)

  vim.notify("Copied: " .. text)

  -- Exit visual mode → normal mode
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
    "n",
    true
  )
end

-- Visual mode mappings
vim.keymap.set("v", "cp", function()
  copy_path_line_cols({ absolute = false })
end, { silent = true, desc = "Copy relative path + selection" })

vim.keymap.set("v", "cP", function()
  copy_path_line_cols({ absolute = true })
end, { silent = true, desc = "Copy absolute path + selection" })

-- Python interpreter selector
local python_selector = require("python_selector")

-- Load persisted interpreter on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    python_selector.load_persisted()
  end,
  desc = "Load persisted Python interpreter",
})

-- User command for selection
vim.api.nvim_create_user_command("SelectPythonInterpreter", function()
  python_selector.select_interpreter()
end, {
  desc = "Select Python interpreter for DAP and LSP",
})
