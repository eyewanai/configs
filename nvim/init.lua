-- Minimal terminal-first Neovim: reading, navigation, small edits.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.mouse = "a"
opt.number = true
opt.relativenumber = false
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.cursorline = true
opt.splitright = true
opt.splitbelow = true
opt.ignorecase = true
opt.smartcase = true
opt.scrolloff = 5
opt.sidescrolloff = 8
opt.wrap = false
opt.updatetime = 500
opt.timeoutlen = 400
opt.completeopt = { "menuone", "noselect" }
opt.undofile = true
opt.laststatus = 3

-- Kitty's dim-glass palette. The terminal still owns the font.
local function apply_dim_glass()
  local c = {
    bg = "#1f2327",
    panel = "#24282d",
    border = "#4a525b",
    fg = "#c8ccd1",
    bright = "#dfe3e8",
    muted = "#7c848e",
    faint = "#4e565f",
    red = "#d08c86",
    green = "#9bb88a",
    yellow = "#d3ae7a",
    blue = "#8fa8c9",
    magenta = "#b79ac0",
    cyan = "#86afb5",
    selection = "#3a4149",
  }

  local groups = {
    Normal = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = c.panel },
    SignColumn = { bg = c.bg },
    EndOfBuffer = { fg = c.bg, bg = c.bg },
    CursorLine = { bg = c.panel },
    CursorLineNr = { fg = c.yellow, bold = true },
    LineNr = { fg = c.muted },
    WinSeparator = { fg = c.border },
    VertSplit = { fg = c.border },
    FloatBorder = { fg = c.border, bg = c.panel },
    Pmenu = { fg = c.fg, bg = c.panel },
    PmenuSel = { fg = c.bright, bg = c.selection },
    Search = { fg = c.bg, bg = c.yellow },
    IncSearch = { fg = c.bg, bg = c.cyan },
    Visual = { bg = c.selection },
    Comment = { fg = c.muted },
    Constant = { fg = c.cyan },
    String = { fg = c.green },
    Character = { fg = c.green },
    Number = { fg = c.cyan },
    Boolean = { fg = c.cyan },
    Identifier = { fg = c.fg },
    Function = { fg = c.blue },
    Statement = { fg = c.magenta },
    Keyword = { fg = c.magenta },
    Type = { fg = c.yellow },
    Special = { fg = c.cyan },
    Error = { fg = c.red },
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.yellow },
    DiagnosticInfo = { fg = c.cyan },
    DiagnosticHint = { fg = c.muted },
    DiagnosticUnderlineError = { undercurl = true, sp = c.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
    DiagnosticUnderlineInfo = { undercurl = true, sp = c.cyan },
    DiagnosticUnderlineHint = { undercurl = true, sp = c.muted },
    DiffAdd = { fg = c.green, bg = "#293329" },
    DiffChange = { fg = c.yellow, bg = "#332f25" },
    DiffDelete = { fg = c.red, bg = "#332827" },
    DiffText = { fg = c.bright, bg = "#3b3629" },
    Added = { fg = c.green },
    Changed = { fg = c.yellow },
    Removed = { fg = c.red },
    GitSignsAdd = { fg = c.green, bg = c.bg },
    GitSignsChange = { fg = c.yellow, bg = c.bg },
    GitSignsDelete = { fg = c.red, bg = c.bg },
    -- Tree-sitter captures.
    ["@comment"] = { fg = c.muted },
    ["@string"] = { fg = c.green },
    ["@number"] = { fg = c.cyan },
    ["@boolean"] = { fg = c.cyan },
    ["@constant"] = { fg = c.cyan },
    ["@variable"] = { fg = c.fg },
    ["@parameter"] = { fg = c.fg },
    ["@function"] = { fg = c.blue },
    ["@function.call"] = { fg = c.blue },
    ["@method"] = { fg = c.blue },
    ["@method.call"] = { fg = c.blue },
    ["@keyword"] = { fg = c.magenta },
    ["@type"] = { fg = c.yellow },
    ["@property"] = { fg = c.cyan },
    ["@operator"] = { fg = c.fg },
    ["@punctuation.bracket"] = { fg = c.muted },
    ["@punctuation.delimiter"] = { fg = c.muted },
    ["@lsp.type.function"] = { fg = c.blue },
    ["@lsp.type.method"] = { fg = c.blue },
    ["@lsp.type.type"] = { fg = c.yellow },
  }

  for group, style in pairs(groups) do
    vim.api.nvim_set_hl(0, group, style)
  end
  vim.g.colors_name = "dim-glass"
end

apply_dim_glass()

-- Bootstrap the small plugin manager.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
opt.rtp:prepend(lazypath)

local treesitter_languages = {
  "bash", "go", "gomod", "gowork", "json", "lua", "markdown",
  "markdown_inline", "query", "toml", "vim", "vimdoc", "yaml",
}

require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
      require("nvim-treesitter").install(treesitter_languages)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "bash", "go", "gomod", "gowork", "json", "lua", "markdown", "query", "toml", "vim", "yaml" },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files({ hidden = true }) end, desc = "Find files" },
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Grep project" },
      { "<leader>fr", function() require("telescope.builtin").oldfiles() end, desc = "Recent files" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top", height = 0.85, width = 0.85 },
        prompt_prefix = "  ",
        selection_caret = "  ",
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Project tree" },
      { "<leader>ef", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal current file" },
    },
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        disable_netrw = true,
        hijack_netrw = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        hijack_cursor = true,
        update_focused_file = { enable = true, update_root = true },
        view = { width = 32, side = "left", preserve_window_proportions = true },
        renderer = {
          group_empty = true,
          highlight_git = "name",
          icons = {
            web_devicons = {
              file = { enable = true, color = true },
              folder = { enable = true, color = true },
            },
            git_placement = "before",
            show = {
              file = true,
              folder = true,
              git = true,
              modified = false,
              hidden = false,
              diagnostics = false,
            },
          },
        },
        git = {
          enable = true,
          show_on_dirs = true,
          show_on_open_dirs = true,
          timeout = 500,
        },
        diagnostics = { enable = false },
        filesystem_watchers = { enable = false },
        actions = {
          open_file = { quit_on_open = false, resize_window = false },
          change_dir = { enable = true, global = false },
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.set("n", "<LeftRelease>", api.node.open.edit, {
            buffer = bufnr,
            desc = "Open with single click",
            silent = true,
          })
          for group, color in pairs({
            NvimTreeGitNew = "#9bb88a",
            NvimTreeGitStaged = "#9bb88a",
            NvimTreeGitDirty = "#d3ae7a",
            NvimTreeGitRenamed = "#8fa8c9",
            NvimTreeGitDeleted = "#d08c86",
            NvimTreeGitMerge = "#b79ac0",
            NvimTreeGitIgnored = "#7c848e",
          }) do
            vim.api.nvim_set_hl(0, group, { fg = color })
          end
        end,
      })
    end,
  },
  {
    "stevearc/oil.nvim",
    keys = {
      { "<leader>o", function() require("oil").open_float() end, desc = "Oil file viewer" },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = { show_hidden = true },
      float = { padding = 2, max_width = 100, max_height = 30, border = "rounded" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = { add = { text = "▎" }, change = { text = "▎" }, delete = { text = "_" }, topdelete = { text = "‾" }, changedelete = { text = "▎" } },
      current_line_blame = false,
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "]c", function() gs.nav_hunk("next") end, "Next git hunk")
        map("n", "[c", function() gs.nav_hunk("prev") end, "Previous git hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview git hunk")
        map("n", "<leader>hd", gs.diffthis, "Buffer git diff")
      end,
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local function on_attach(client, bufnr)
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gr", function() require("telescope.builtin").lsp_references() end, "Find references")
        map("K", vim.lsp.buf.hover, "Hover documentation")
        vim.keymap.set("n", "<C-LeftMouse>", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
        vim.keymap.set("n", "<D-LeftMouse>", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
        vim.api.nvim_buf_create_user_command(bufnr, "LspInfo", function()
          vim.cmd("checkhealth vim.lsp")
        end, {})
      end

      vim.lsp.config("gopls", {
        capabilities = capabilities,
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_dir = function(bufnr, on_dir)
          local root = vim.fs.root(vim.api.nvim_buf_get_name(bufnr), { "go.work", "go.mod", ".git" })
          if root then on_dir(root) end
        end,
        settings = {
          gopls = {
            analyses = { unusedparams = true, shadow = true },
            staticcheck = false,
            semanticTokens = true,
            usePlaceholders = true,
            completeUnimported = false,
          },
        },
        on_attach = on_attach,
      })
      vim.lsp.enable("gopls")
    end,
  },
}, {
  change_detection = { notify = false },
  checker = { enabled = false },
  install = { colorscheme = { "habamax" } },
})

-- With no file argument, show the current project directory instead of a blank buffer.
vim.schedule(function()
  if vim.fn.argc() == 0 and vim.bo.buftype == "" and vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
    require("nvim-tree.api").tree.open()
  end
end)

local function open_lazygit()
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("lazygit is not available in PATH", vim.log.levels.WARN)
    return
  end
  local root = vim.fs.root(vim.fn.getcwd(), { ".git" }) or vim.fn.getcwd()
  vim.cmd("tabnew")
  local tab = vim.api.nvim_get_current_tabpage()
  local buffer = vim.api.nvim_get_current_buf()
  vim.fn.jobstart({ "lazygit" }, {
    cwd = root,
    term = true,
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_tabpage_is_valid(tab) then
          vim.api.nvim_set_current_tabpage(tab)
          pcall(vim.cmd, "tabclose")
        elseif vim.api.nvim_buf_is_valid(buffer) then
          vim.api.nvim_buf_delete(buffer, { force = true })
        end
      end)
    end,
  })
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>gg", open_lazygit, { desc = "Open lazygit" })

-- Jump list navigation: Ctrl-O/Ctrl-I remain the standard Vim bindings.
vim.keymap.set("n", "<A-Left>", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "<A-Right>", "<C-i>", { desc = "Jump forward" })
vim.keymap.set("n", "<D-[>", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "<D-]>", "<C-i>", { desc = "Jump forward" })
vim.keymap.set("n", "<X1Mouse>", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "<X2Mouse>", "<C-i>", { desc = "Jump forward" })

-- Refresh project/git status when returning to Neovim after an agent changes files.
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    if package.loaded["nvim-tree.api"] then
      pcall(require("nvim-tree.api").tree.reload)
    end
  end,
})

-- Mouse selection is a Vim visual selection; copy it to the macOS clipboard.
vim.keymap.set("v", "<C-c>", '"+y', { silent = true, desc = "Copy selection" })
vim.keymap.set("v", "<D-c>", '"+y', { silent = true, desc = "Copy selection" })

vim.diagnostic.config({
  signs = true,
  underline = true,
  virtual_text = { spacing = 2, prefix = "·" },
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

vim.keymap.set("n", "<leader>d", function()
  vim.diagnostic.open_float(nil, { scope = "cursor", focus = false, border = "rounded", source = "if_many" })
end, { desc = "Show diagnostic" })

-- Pause on a symbol: show its LSP type/signature/docs, or the diagnostic at the cursor.
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.fn.expand("<cword>") == "" then return end
    if #vim.diagnostic.get(args.buf, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 }) > 0 then
      vim.diagnostic.open_float(args.buf, {
        scope = "cursor",
        focus = false,
        border = "rounded",
        source = "if_many",
      })
    elseif #vim.lsp.get_clients({ bufnr = args.buf }) > 0 then
      vim.lsp.buf.hover({ focus = false, border = "rounded" })
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
  end,
})
