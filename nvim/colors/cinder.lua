-- Cinder — тёплый угольный фон с вулканическими акцентами.
--
-- Палитра общая с ~/.config/kitty/cinder.conf и ~/.config/zed/themes/cinder.json:
-- значения обязаны совпадать, иначе kitty, Zed и nvim разъедутся. Акценты
-- держатся в полосе L* 65–72 и дают контраст к фону не ниже 4.5:1, кроме
-- намеренно приглушённых Ghost/Unnecessary.
--
-- Шрифт темой не задаётся — им владеет терминал (сейчас Maple Mono NF).

local c = {
  bg          = "#1a1715", -- фон редактора
  bg_deep     = "#14110f", -- панели: дерево, статусная строка
  bg_raised   = "#201c19", -- всплывающие окна, меню
  bg_hover    = "#272220",
  bg_active   = "#332c27",
  line_hl     = "#221e1b", -- текущая строка
  selection   = "#3f342b",
  border      = "#2f2925",
  border_soft = "#241f1c",
  focus       = "#8a6440",

  fg          = "#e6ddd3",
  property    = "#c9beb2",
  param       = "#bfb0a2",
  operator    = "#b09f92",
  muted       = "#a1968b",
  punct       = "#9c9086",
  doc         = "#988c80",
  comment     = "#8c7f73",
  dim         = "#786d63",
  faint       = "#5c5249",
  ghost       = "#6b6058",

  rose        = "#ea8073", -- ключевые слова, теги, ошибки
  rose_br     = "#ee978c",
  ember       = "#ea904d", -- числа, константы; опознавательный акцент
  ember_br    = "#ff9d54",
  gold        = "#d4aa60", -- функции, атрибуты
  gold_br     = "#e8ba69",
  moss        = "#9bb46e", -- строки
  moss_br     = "#aac579",
  aqua        = "#6fb9a5", -- типы
  aqua_br     = "#79cab5",
  sky         = "#81abcc", -- ссылки, info
  sky_br      = "#8dbbe0",
  heather     = "#c992bc", -- препроцессор, декораторы
  heather_br  = "#dda0cf",

  cursor      = "#f5964e",
  black_br    = "#4a423b",
  white       = "#d8cdc2",
  white_br    = "#f2ebe3",
}

-- Смешивание поверх фона: терминал не умеет альфа-канал, поэтому подложки
-- диагностик и диффов считаются заранее.
local function blend(top, bottom, alpha)
  local function rgb(h)
    return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
  end
  local r1, g1, b1 = rgb(top)
  local r2, g2, b2 = rgb(bottom)
  return string.format("#%02x%02x%02x",
    math.floor(r1 * alpha + r2 * (1 - alpha) + 0.5),
    math.floor(g1 * alpha + g2 * (1 - alpha) + 0.5),
    math.floor(b1 * alpha + b2 * (1 - alpha) + 0.5))
end

c.bg_error = blend(c.rose, c.bg, 0.13)
c.bg_warn  = blend(c.gold, c.bg, 0.13)
c.bg_info  = blend(c.sky, c.bg, 0.13)
c.bg_hint  = blend(c.aqua, c.bg, 0.13)
c.bg_add   = blend(c.moss, c.bg, 0.16)
c.bg_del   = blend(c.rose, c.bg, 0.16)
c.bg_chg   = blend(c.gold, c.bg, 0.14)
c.bg_text  = blend(c.gold, c.bg, 0.26)

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.o.background = "dark"
vim.g.colors_name = "cinder"

local hl = {
  -- ── База ────────────────────────────────────────────────────────────────
  Normal        = { fg = c.fg, bg = c.bg },
  NormalNC      = { fg = c.fg, bg = c.bg },
  NormalFloat   = { fg = c.fg, bg = c.bg_raised },
  FloatBorder   = { fg = c.border, bg = c.bg_raised },
  FloatTitle    = { fg = c.ember, bg = c.bg_raised, bold = true },
  Cursor        = { fg = c.bg, bg = c.cursor },
  lCursor       = { fg = c.bg, bg = c.cursor },
  TermCursor    = { fg = c.bg, bg = c.cursor },
  CursorLine    = { bg = c.line_hl },
  CursorColumn  = { bg = c.line_hl },
  ColorColumn   = { bg = c.bg_raised },
  CursorLineNr  = { fg = c.ember, bold = true },
  LineNr        = { fg = c.faint },
  LineNrAbove   = { fg = c.faint },
  LineNrBelow   = { fg = c.faint },
  SignColumn    = { bg = c.bg },
  FoldColumn    = { fg = c.faint, bg = c.bg },
  Folded        = { fg = c.muted, bg = c.bg_raised },
  EndOfBuffer   = { fg = c.bg },
  NonText       = { fg = c.faint },
  SpecialKey    = { fg = c.faint },
  Whitespace    = { fg = c.border },
  Conceal       = { fg = c.dim },
  Directory     = { fg = c.sky },
  Title         = { fg = c.gold_br, bold = true },
  MatchParen    = { fg = c.ember, bg = c.bg_active, bold = true },
  Visual        = { bg = c.selection },
  VisualNOS     = { bg = c.selection },
  Search        = { fg = c.bg, bg = c.gold },
  IncSearch     = { fg = c.bg, bg = c.ember },
  CurSearch     = { fg = c.bg, bg = c.ember_br },
  Substitute    = { fg = c.bg, bg = c.rose },
  QuickFixLine  = { bg = c.bg_active },
  WinSeparator  = { fg = c.border, bg = c.bg },
  VertSplit     = { fg = c.border, bg = c.bg },

  -- ── Хром в духе Zed ─────────────────────────────────────────────────────
  -- Нижняя строка на фоне редактора: таб-бар уехал наверх, и под ней теперь
  -- только остаток неполной строки, залитый тем же #1a1715. Полоса тихая, её
  -- держат не подложкой, а иерархией контраста в группах Zed* ниже.
  StatusLine    = { fg = c.muted, bg = c.bg },
  StatusLineNC  = { fg = c.faint, bg = c.bg },
  WinBar        = { fg = c.dim, bg = c.bg },
  WinBarNC      = { fg = c.faint, bg = c.bg },
  TabLine       = { fg = c.dim, bg = c.bg_deep },
  TabLineFill   = { bg = c.bg_deep },
  TabLineSel    = { fg = c.ember, bg = c.bg },
  MsgArea       = { fg = c.muted },
  ModeMsg       = { fg = c.ember },
  MoreMsg       = { fg = c.aqua },
  Question      = { fg = c.aqua },
  ErrorMsg      = { fg = c.rose },
  WarningMsg    = { fg = c.gold },

  -- Собственные группы статусной строки и хлебных крошек
  -- Иерархия по контрасту на фоне #14110f: проект 10.3:1, ветка 6.5:1,
  -- разделитель 3.7:1. faint здесь давал 2.5:1 и точку было не разглядеть.
  ZedProject    = { fg = c.property, bg = c.bg },
  ZedSep        = { fg = c.dim, bg = c.bg },
  ZedBranch     = { fg = c.muted, bg = c.bg },
  ZedMode       = { fg = c.ember, bg = c.bg, bold = true },
  ZedDiagError  = { fg = c.rose, bg = c.bg },
  ZedDiagWarn   = { fg = c.gold, bg = c.bg },
  ZedCrumb      = { fg = c.dim, bg = c.bg },
  ZedCrumbSep   = { fg = c.faint, bg = c.bg },
  ZedCrumbFile  = { fg = c.property, bg = c.bg },

  -- ── Меню автодополнения ─────────────────────────────────────────────────
  Pmenu         = { fg = c.fg, bg = c.bg_raised },
  PmenuSel      = { fg = c.white_br, bg = c.bg_active, bold = true },
  PmenuKind     = { fg = c.aqua, bg = c.bg_raised },
  PmenuExtra    = { fg = c.dim, bg = c.bg_raised },
  PmenuSbar     = { bg = c.bg_raised },
  PmenuThumb    = { bg = c.border },
  WildMenu      = { fg = c.bg, bg = c.ember },

  -- ── Классический синтаксис ──────────────────────────────────────────────
  Comment        = { fg = c.comment, italic = true },
  SpecialComment = { fg = c.doc, italic = true },
  Todo           = { fg = c.bg, bg = c.gold, bold = true },
  Constant       = { fg = c.ember },
  String         = { fg = c.moss },
  Character      = { fg = c.moss },
  Number         = { fg = c.ember },
  Float          = { fg = c.ember },
  Boolean        = { fg = c.ember },
  Identifier     = { fg = c.fg },
  Function       = { fg = c.gold },
  Statement      = { fg = c.rose },
  Conditional    = { fg = c.rose },
  Repeat         = { fg = c.rose },
  Label          = { fg = c.heather },
  Operator       = { fg = c.operator },
  Keyword        = { fg = c.rose },
  Exception      = { fg = c.rose },
  PreProc        = { fg = c.heather },
  Include        = { fg = c.heather },
  Define         = { fg = c.heather },
  Macro          = { fg = c.heather },
  PreCondit      = { fg = c.heather },
  Type           = { fg = c.aqua },
  StorageClass   = { fg = c.rose },
  Structure      = { fg = c.aqua },
  Typedef        = { fg = c.aqua },
  Special        = { fg = c.ember },
  SpecialChar    = { fg = c.ember },
  Tag            = { fg = c.rose },
  Delimiter      = { fg = c.punct },
  Debug          = { fg = c.rose },
  Underlined     = { fg = c.sky, underline = true },
  Ignore         = { fg = c.faint },
  Error          = { fg = c.rose },

  -- ── Диагностика ─────────────────────────────────────────────────────────
  DiagnosticError            = { fg = c.rose },
  DiagnosticWarn             = { fg = c.gold },
  DiagnosticInfo             = { fg = c.sky },
  DiagnosticHint             = { fg = c.aqua },
  DiagnosticOk               = { fg = c.moss },
  DiagnosticVirtualTextError = { fg = c.rose, bg = c.bg_error },
  DiagnosticVirtualTextWarn  = { fg = c.gold, bg = c.bg_warn },
  DiagnosticVirtualTextInfo  = { fg = c.sky, bg = c.bg_info },
  DiagnosticVirtualTextHint  = { fg = c.aqua, bg = c.bg_hint },
  DiagnosticUnderlineError   = { undercurl = true, sp = c.rose },
  DiagnosticUnderlineWarn    = { undercurl = true, sp = c.gold },
  DiagnosticUnderlineInfo    = { undercurl = true, sp = c.sky },
  DiagnosticUnderlineHint    = { undercurl = true, sp = c.aqua },
  -- Аналог unnecessary_code_fade из Zed
  DiagnosticUnnecessary      = { fg = c.ghost },
  DiagnosticDeprecated       = { fg = c.dim, strikethrough = true },

  -- ── Диффы и git ─────────────────────────────────────────────────────────
  DiffAdd        = { fg = c.moss, bg = c.bg_add },
  DiffChange     = { fg = c.gold, bg = c.bg_chg },
  DiffDelete     = { fg = c.rose, bg = c.bg_del },
  DiffText       = { fg = c.white_br, bg = c.bg_text },
  Added          = { fg = c.moss },
  Changed        = { fg = c.gold },
  Removed        = { fg = c.rose },
  GitSignsAdd    = { fg = c.moss, bg = c.bg },
  GitSignsChange = { fg = c.gold, bg = c.bg },
  GitSignsDelete = { fg = c.rose, bg = c.bg },
  GitSignsAddLn      = { bg = c.bg_add },
  GitSignsChangeLn   = { bg = c.bg_chg },
  GitSignsDeleteLn   = { bg = c.bg_del },
  GitSignsCurrentLineBlame = { fg = c.faint, italic = true },

  -- ── Tree-sitter ─────────────────────────────────────────────────────────
  ["@comment"]                = { fg = c.comment, italic = true },
  ["@comment.documentation"]  = { fg = c.doc, italic = true },
  ["@comment.error"]          = { fg = c.rose },
  ["@comment.warning"]        = { fg = c.gold },
  ["@comment.todo"]           = { fg = c.bg, bg = c.gold, bold = true },
  ["@comment.note"]           = { fg = c.bg, bg = c.aqua, bold = true },

  ["@keyword"]                = { fg = c.rose },
  ["@keyword.function"]       = { fg = c.rose },
  ["@keyword.return"]         = { fg = c.rose },
  ["@keyword.operator"]       = { fg = c.rose },
  ["@keyword.import"]         = { fg = c.heather },
  ["@keyword.directive"]      = { fg = c.heather },
  ["@keyword.exception"]      = { fg = c.rose },
  ["@conditional"]            = { fg = c.rose },
  ["@repeat"]                 = { fg = c.rose },
  ["@operator"]               = { fg = c.operator },
  ["@punctuation.bracket"]    = { fg = c.punct },
  ["@punctuation.delimiter"]  = { fg = c.punct },
  ["@punctuation.special"]    = { fg = c.ember },

  ["@string"]                 = { fg = c.moss },
  ["@string.escape"]          = { fg = c.ember },
  ["@string.regexp"]          = { fg = c.aqua_br },
  ["@string.special"]         = { fg = c.moss_br },
  ["@string.special.symbol"]  = { fg = c.gold },
  ["@string.special.url"]     = { fg = c.sky, underline = true },
  ["@character"]              = { fg = c.moss },

  ["@number"]                 = { fg = c.ember },
  ["@number.float"]           = { fg = c.ember },
  ["@boolean"]                = { fg = c.ember },
  ["@constant"]               = { fg = c.ember },
  ["@constant.builtin"]       = { fg = c.ember },
  ["@constant.macro"]         = { fg = c.heather },

  ["@function"]               = { fg = c.gold },
  ["@function.call"]          = { fg = c.gold },
  ["@function.builtin"]       = { fg = c.gold },
  ["@function.method"]        = { fg = c.gold },
  ["@function.method.call"]   = { fg = c.gold },
  ["@function.macro"]         = { fg = c.heather },
  ["@constructor"]            = { fg = c.aqua_br },

  ["@type"]                   = { fg = c.aqua },
  ["@type.builtin"]           = { fg = c.aqua },
  ["@type.definition"]        = { fg = c.aqua_br },
  ["@type.qualifier"]         = { fg = c.rose },
  ["@module"]                 = { fg = c.aqua_br },
  ["@namespace"]              = { fg = c.aqua_br },

  ["@variable"]               = { fg = c.fg },
  ["@variable.builtin"]       = { fg = c.heather },
  ["@variable.parameter"]     = { fg = c.param, italic = true },
  ["@variable.member"]        = { fg = c.property },
  ["@property"]               = { fg = c.property },
  ["@field"]                  = { fg = c.property },
  ["@parameter"]              = { fg = c.param, italic = true },
  ["@attribute"]              = { fg = c.gold },
  ["@label"]                  = { fg = c.heather },

  ["@tag"]                    = { fg = c.rose },
  ["@tag.builtin"]            = { fg = c.rose },
  ["@tag.attribute"]          = { fg = c.gold },
  ["@tag.delimiter"]          = { fg = c.punct },

  ["@markup.heading"]         = { fg = c.gold_br, bold = true },
  ["@markup.strong"]          = { fg = c.gold, bold = true },
  ["@markup.italic"]          = { fg = c.gold, italic = true },
  ["@markup.strikethrough"]   = { fg = c.dim, strikethrough = true },
  ["@markup.link"]            = { fg = c.aqua, italic = true },
  ["@markup.link.url"]        = { fg = c.sky, underline = true },
  ["@markup.raw"]             = { fg = c.moss },
  ["@markup.list"]            = { fg = c.ember },
  ["@markup.quote"]           = { fg = c.muted, italic = true },
  ["@diff.plus"]              = { fg = c.moss, bg = c.bg_add },
  ["@diff.minus"]             = { fg = c.rose, bg = c.bg_del },

  -- ── Семантические токены LSP ────────────────────────────────────────────
  ["@lsp.type.function"]      = { fg = c.gold },
  ["@lsp.type.method"]        = { fg = c.gold },
  ["@lsp.type.type"]          = { fg = c.aqua },
  ["@lsp.type.class"]         = { fg = c.aqua },
  ["@lsp.type.interface"]     = { fg = c.aqua_br },
  ["@lsp.type.struct"]        = { fg = c.aqua },
  ["@lsp.type.enum"]          = { fg = c.aqua },
  ["@lsp.type.enumMember"]    = { fg = c.ember },
  ["@lsp.type.namespace"]     = { fg = c.aqua_br },
  ["@lsp.type.parameter"]     = { fg = c.param, italic = true },
  ["@lsp.type.property"]      = { fg = c.property },
  ["@lsp.type.variable"]      = { fg = c.fg },
  ["@lsp.type.keyword"]       = { fg = c.rose },
  ["@lsp.type.string"]        = { fg = c.moss },
  ["@lsp.type.number"]        = { fg = c.ember },
  ["@lsp.type.comment"]       = { fg = c.comment, italic = true },
  ["@lsp.type.decorator"]     = { fg = c.heather },
  ["@lsp.mod.deprecated"]     = { fg = c.dim, strikethrough = true },
  LspInlayHint                = { fg = c.ghost, bg = c.bg_raised, italic = true },
  LspReferenceText            = { bg = c.bg_active },
  LspReferenceRead            = { bg = c.bg_active },
  LspReferenceWrite           = { bg = c.bg_active, underline = true },
  LspSignatureActiveParameter = { fg = c.ember, bold = true },

  -- ── Панель проекта (аналог project panel в Zed) ─────────────────────────
  NvimTreeNormal        = { fg = c.muted, bg = c.bg_deep },
  NvimTreeNormalNC      = { fg = c.muted, bg = c.bg_deep },
  NvimTreeEndOfBuffer   = { fg = c.bg_deep, bg = c.bg_deep },
  NvimTreeWinSeparator  = { fg = c.bg_deep, bg = c.bg_deep },
  NvimTreeRootFolder    = { fg = c.dim, italic = true },
  NvimTreeFolderName    = { fg = c.muted },
  NvimTreeOpenedFolderName   = { fg = c.fg },
  NvimTreeEmptyFolderName    = { fg = c.faint },
  NvimTreeFolderIcon    = { fg = c.dim },
  NvimTreeOpenedFile    = { fg = c.fg, bold = true },
  NvimTreeSpecialFile   = { fg = c.gold },
  NvimTreeCursorLine    = { bg = c.bg_active },
  NvimTreeIndentMarker  = { fg = c.border_soft },
  NvimTreeGitNew        = { fg = c.moss },
  NvimTreeGitStaged     = { fg = c.moss },
  NvimTreeGitDirty      = { fg = c.gold },
  NvimTreeGitRenamed    = { fg = c.sky },
  NvimTreeGitDeleted    = { fg = c.rose },
  NvimTreeGitMerge      = { fg = c.heather },
  NvimTreeGitIgnored    = { fg = c.faint },

  -- ── Telescope (аналог file finder / палитры команд) ─────────────────────
  TelescopeNormal        = { fg = c.fg, bg = c.bg_raised },
  TelescopeBorder        = { fg = c.border, bg = c.bg_raised },
  TelescopeTitle         = { fg = c.ember, bold = true },
  TelescopePromptNormal  = { fg = c.fg, bg = c.bg_hover },
  TelescopePromptBorder  = { fg = c.bg_hover, bg = c.bg_hover },
  TelescopePromptTitle   = { fg = c.bg, bg = c.ember, bold = true },
  TelescopePromptPrefix  = { fg = c.ember, bg = c.bg_hover },
  TelescopePromptCounter = { fg = c.faint, bg = c.bg_hover },
  TelescopeResultsNormal = { fg = c.muted, bg = c.bg_raised },
  TelescopeResultsBorder = { fg = c.bg_raised, bg = c.bg_raised },
  TelescopeResultsTitle  = { fg = c.bg_raised, bg = c.bg_raised },
  TelescopePreviewNormal = { fg = c.fg, bg = c.bg },
  TelescopePreviewBorder = { fg = c.border, bg = c.bg },
  TelescopePreviewTitle  = { fg = c.moss, bold = true },
  TelescopeSelection     = { fg = c.white_br, bg = c.bg_active, bold = true },
  TelescopeSelectionCaret = { fg = c.ember, bg = c.bg_active },
  TelescopeMatching      = { fg = c.ember, bold = true },
  TelescopeMultiSelection = { fg = c.aqua },

  -- ── Oil ─────────────────────────────────────────────────────────────────
  OilDir      = { fg = c.sky },
  OilDirIcon  = { fg = c.dim },
  OilLink     = { fg = c.aqua, italic = true },
  OilFile     = { fg = c.fg },
  OilCreate   = { fg = c.moss },
  OilDelete   = { fg = c.rose },
  OilMove     = { fg = c.sky },
  OilCopy     = { fg = c.gold },
  OilChange   = { fg = c.gold },
}

for group, spec in pairs(hl) do
  vim.api.nvim_set_hl(0, group, spec)
end

-- Палитра ANSI для :terminal внутри nvim — те же 16 цветов, что в kitty.
local ansi = {
  c.border_soft, c.rose, c.moss, c.gold, c.sky, c.heather, c.aqua, c.white,
  c.black_br, c.rose_br, c.moss_br, c.gold_br, c.sky_br, c.heather_br, c.aqua_br, c.white_br,
}
for i, color in ipairs(ansi) do
  vim.g["terminal_color_" .. (i - 1)] = color
end

return c
