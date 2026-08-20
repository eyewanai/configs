-- Minimal terminal-first Neovim: reading, navigation, small edits.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.mouse = "a"
opt.number = true
opt.relativenumber = false
-- Буфер обмена. На macOS провайдер встроен, на Linux нужен внешний: без
-- wl-copy/xclip/xsel настройка unnamedplus печатает "clipboard: No provider"
-- на каждый рывок, поэтому включаем её только когда есть чем работать.
if vim.fn.has("mac") == 1
  or vim.fn.executable("wl-copy") == 1
  or vim.fn.executable("xclip") == 1
  or vim.fn.executable("xsel") == 1
then
  opt.clipboard = "unnamedplus"
end
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
opt.pumheight = 12
opt.winborder = "rounded"     -- плавающие окна скруглены, как панели Zed

-- Cinder — палитра в colors/cinder.lua, общая с kitty и Zed.
-- Шрифтом владеет терминал (Maple Mono NF), тема его не трогает.
vim.cmd.colorscheme("cinder")

-- Хром в духе Zed: нет вкладок, есть хлебные крошки и тихая нижняя строка.
require("zed_ui").setup()

-- Bootstrap the small plugin manager.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
opt.rtp:prepend(lazypath)

local treesitter_languages = require("languages")

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
          -- Без подписи корня: путь уже виден в нижней строке (имя проекта)
          -- и в хлебных крошках над буфером, третий раз он лишний.
          root_folder_label = false,
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
          -- Цвета NvimTreeGit* задаёт colors/cinder.lua.
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
      -- silent: без него каждая пауза на символе без документации печатает
      -- "No information available". Ручной K намеренно оставлен болтливым.
      vim.lsp.buf.hover({ focus = false, border = "rounded", silent = true })
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
  end,
})

-- nvim-tree и другие плагины с lazy=false выставляют собственные группы во
-- время инициализации. Один перекрас после старта возвращает палитру Cinder.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function() vim.cmd.colorscheme("cinder") end,
})
