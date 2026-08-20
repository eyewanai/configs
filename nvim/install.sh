#!/usr/bin/env bash

set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_root=${XDG_CONFIG_HOME:-"$HOME/.config"}
target="$config_root/nvim"

have() { command -v "$1" >/dev/null 2>&1; }
# printf %-14s выравнивает по байтам, а кириллическая метка занимает по два
# на символ и колонка разъезжается. ${#var} в UTF-8-локали считает символы,
# поэтому отступ добиваем вручную.
report() {
  local label=$1 width=14 pad=""
  if [ "${#label}" -lt "$width" ]; then
    pad=$(printf '%*s' "$((width - ${#label}))" '')
  fi
  printf '  %s%s %s\n' "$label" "$pad" "$2"
}

missing_required=0

# ── Проверки до симлинка ────────────────────────────────────────────────────
#
# Всё, что обязательно, проверяется ДО того, как трогать ~/.config/nvim.
# Иначе при нехватке зависимостей получается наполовину установленное
# состояние: симлинк уже подменил конфигурацию, а плагины не встали.

printf 'Обязательные зависимости:\n'

if have nvim; then
  # sed, а не head: head закрывает пайп раньше времени и при pipefail
  # роняет весь скрипт по SIGPIPE.
  report nvim "$(nvim --version | sed -n '1p')"
else
  report nvim 'НЕ НАЙДЕН'
  missing_required=1
fi

if have git; then
  report git 'найден'
else
  report git 'НЕ НАЙДЕН'
  missing_required=1
fi

# nvim-treesitter компилирует парсеры из исходников на C. Без компилятора
# установка сыплет ошибкой на каждом языке из списка — на чистой Linux-машине
# это самая частая причина «кучи ошибок» при первом запуске.
compiler=""
for candidate in cc gcc clang; do
  if have "$candidate"; then
    compiler=$candidate
    break
  fi
done
if [ -n "$compiler" ]; then
  report 'C-компилятор' "$compiler"
else
  report 'C-компилятор' 'НЕ НАЙДЕН — Treesitter не соберёт парсеры'
  missing_required=1
fi

printf '\nДополнительные:\n'
for command_name in rg go gopls lazygit; do
  if have "$command_name"; then
    report "$command_name" 'найден'
  else
    report "$command_name" 'не найден'
  fi
done

# Буфер обмена. На macOS провайдер встроен в систему, на Linux его нет:
# без xclip/xsel/wl-copy настройка clipboard=unnamedplus печатает
# "clipboard: No provider" на каждое копирование.
if [ "$(uname -s)" = "Linux" ]; then
  clipboard_tool=""
  for candidate in wl-copy xclip xsel; do
    if have "$candidate"; then
      clipboard_tool=$candidate
      break
    fi
  done
  if [ -n "$clipboard_tool" ]; then
    report 'буфер обмена' "$clipboard_tool"
  else
    report 'буфер обмена' 'не найден (нужен wl-copy, xclip или xsel)'
  fi
fi

if [ "$missing_required" -ne 0 ]; then
  printf '\n%s\n' 'Не хватает обязательных зависимостей, установка прервана.' >&2
  printf '%s\n' 'Конфигурация не тронута. Подсказки по пакетам — в nvim/README.md.' >&2
  exit 1
fi

# ── Симлинк ─────────────────────────────────────────────────────────────────

printf '\n'
mkdir -p "$config_root"

if [ -L "$target" ] && [ "$(readlink "$target")" = "$script_dir" ]; then
  printf 'Конфигурация уже подключена: %s\n' "$target"
else
  if [ -e "$target" ] || [ -L "$target" ]; then
    backup="$target.backup.$(date +%Y%m%d-%H%M%S)"
    mv "$target" "$backup"
    printf 'Старая конфигурация сохранена в: %s\n' "$backup"
  fi
  ln -s "$script_dir" "$target"
  printf 'Создан симлинк: %s -> %s\n' "$target" "$script_dir"
fi

# ── Плагины и парсеры ───────────────────────────────────────────────────────
#
# Оба шага намеренно выведены из-под set -e. Симлинк на этом месте уже создан,
# и падение сборки одного парсера не повод обрывать скрипт молча: полезнее
# довести до конца и показать, что именно не собралось.

run_nvim_step() {
  local title=$1 log status
  shift
  log=$(mktemp)
  printf '%s\n' "$title"
  set +e
  nvim --headless "$@" +qa >"$log" 2>&1
  status=$?
  set -e
  if [ "$status" -eq 0 ]; then
    printf '  готово\n'
    rm -f "$log"
  else
    printf '  завершилось с кодом %s\n' "$status" >&2
    printf '  последние строки вывода:\n' >&2
    tail -n 20 "$log" | sed 's/^/    /' >&2
    printf '  полный вывод: %s\n' "$log" >&2
  fi
  return 0
}

run_nvim_step 'Установка плагинов через lazy.nvim...' '+Lazy! sync'
# install() — асинхронная задача, поэтому её нужно дождаться: без wait
# headless-nvim выйдет раньше, чем соберётся первый парсер. Список языков
# берётся из того же модуля, что и в init.lua.
run_nvim_step 'Сборка Treesitter-парсеров...' \
  '+lua require("nvim-treesitter").install(require("languages")):wait(600000)'

printf '\n%s\n' 'Готово. Запусти nvim.'
