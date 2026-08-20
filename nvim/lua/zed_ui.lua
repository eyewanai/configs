-- Хром в духе Zed: без вкладок, с хлебными крошками и тихой нижней строкой.
--
-- Раскладка повторяет то, во что приведён Zed:
--   • вкладок нет вовсе (tab_bar.show = false)
--   • хлебные крошки над буфером — единственное, что называет открытый файл,
--     поэтому они включены намеренно
--   • у терминала нет заголовка окна, поэтому имя проекта и ветка, живущие
--     в title_bar самого Zed, сведены в нижнюю строку
--   • режим vim справа — Zed показывает его там же

local M = {}

-- Имена файлов и веток могут содержать %, который statusline трактует как код.
local function esc(s)
  return (s:gsub("%%", "%%%%"))
end

local MODES = {
  n = "NORMAL", no = "OP-PENDING", nov = "OP-PENDING", noV = "OP-PENDING",
  niI = "NORMAL", niR = "NORMAL", niV = "NORMAL", nt = "NORMAL", ntT = "NORMAL",
  v = "VISUAL", vs = "VISUAL", V = "V-LINE", Vs = "V-LINE",
  ["\22"] = "V-BLOCK", ["\22s"] = "V-BLOCK",
  s = "SELECT", S = "S-LINE", ["\19"] = "S-BLOCK",
  i = "INSERT", ic = "INSERT", ix = "INSERT",
  R = "REPLACE", Rc = "REPLACE", Rx = "REPLACE", Rv = "V-REPLACE",
  c = "COMMAND", cv = "EX", r = "PROMPT", rm = "MORE", ["r?"] = "CONFIRM",
  ["!"] = "SHELL", t = "TERMINAL",
}

function M.statusline()
  local out = {}

  local project = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  out[#out + 1] = "%#ZedProject# " .. esc(project)

  local branch = vim.g.gitsigns_head
  if branch and branch ~= "" then
    out[#out + 1] = " %#ZedSep#·%#ZedBranch# " .. esc(branch)
  end

  out[#out + 1] = "%#StatusLine#%="

  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  if errors > 0 then out[#out + 1] = "%#ZedDiagError#● " .. errors .. "  " end
  if warns > 0 then out[#out + 1] = "%#ZedDiagWarn#▲ " .. warns .. "  " end

  out[#out + 1] = "%#ZedMode#" .. (MODES[vim.api.nvim_get_mode().mode] or "NORMAL") .. " "
  return table.concat(out)
end

function M.winbar()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then return "" end

  local segments = vim.split(vim.fn.fnamemodify(name, ":."), "/", { plain = true, trimempty = true })
  local out = { " " }
  for i, segment in ipairs(segments) do
    if i == #segments then
      out[#out + 1] = "%#ZedCrumbFile#" .. esc(segment)
    else
      out[#out + 1] = "%#ZedCrumb#" .. esc(segment) .. "%#ZedCrumbSep# › "
    end
  end
  if vim.bo.modified then out[#out + 1] = "%#ZedCrumbSep# ●" end
  return table.concat(out)
end

-- Крошки нужны только над обычными файлами: в дереве проекта, плавающих окнах
-- и терминале пустая строка съедала бы ряд впустую.
local function wants_winbar(win)
  if vim.api.nvim_win_get_config(win).relative ~= "" then return false end
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype ~= "" then return false end
  local ft = vim.bo[buf].filetype
  if ft == "NvimTree" or ft == "oil" or ft == "TelescopePrompt" then return false end
  return vim.api.nvim_buf_get_name(buf) ~= ""
end

local function refresh_winbars()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    pcall(function()
      vim.wo[win].winbar = wants_winbar(win) and "%{%v:lua.require'zed_ui'.winbar()%}" or ""
    end)
  end
end

function M.setup()
  vim.opt.showtabline = 0            -- вкладок нет, как в Zed

  -- Одна полоса на всё окно. Её фон совпадает с фоном таб-бара kitty, а он
  -- лежит прямо под ней, так что вместе они читаются как одна тёмная полоса
  -- в два яруса: сведения о проекте сверху, вкладки снизу. Разрывать их
  -- было нечему только после того, как cmdheight ушёл в ноль.
  vim.opt.laststatus = 3

  -- Командная строка не занимает постоянный ряд. Без этого между тёмной
  -- нижней строкой и таб-баром kitty остаётся светлая полоса в одну ячейку,
  -- в которой болтаются сообщения. При наборе : она всплывает поверх и
  -- потом снова исчезает.
  vim.opt.cmdheight = 0
  vim.opt.ruler = false
  vim.opt.showmode = false           -- режим показывает наша строка
  vim.opt.showcmd = false
  vim.opt.fillchars = {
    eob = " ",
    vert = "│",
    horiz = "─",
    horizup = "─",
    horizdown = "─",
    vertleft = "│",
    vertright = "│",
    verthoriz = "┼",
  }

  vim.o.statusline = "%{%v:lua.require'zed_ui'.statusline()%}"

  local group = vim.api.nvim_create_augroup("ZedUi", { clear = true })
  vim.api.nvim_create_autocmd(
    { "BufWinEnter", "WinEnter", "WinNew", "BufEnter", "FileType", "TermOpen" },
    { group = group, callback = vim.schedule_wrap(refresh_winbars) }
  )
  refresh_winbars()
end

return M
