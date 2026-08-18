#!/usr/bin/env bash

set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
config_root=${XDG_CONFIG_HOME:-"$HOME/.config"}
target="$config_root/nvim"

if ! command -v nvim >/dev/null 2>&1; then
  printf '%s\n' 'Ошибка: Neovim не найден в PATH.' >&2
  exit 1
fi

if [ "$(nvim --version | sed -n '1p')" = "" ]; then
  printf '%s\n' 'Ошибка: не удалось определить версию Neovim.' >&2
  exit 1
fi

printf 'Проверка внешних инструментов:\n'
for command_name in git rg go gopls; do
  if command -v "$command_name" >/dev/null 2>&1; then
    printf '  %-8s найден\n' "$command_name"
  else
    printf '  %-8s НЕ найден\n' "$command_name"
  fi
done
if command -v lazygit >/dev/null 2>&1; then
  printf '  %-8s найден\n' lazygit
else
  printf '  %-8s не найден (дополнительно)\n' lazygit
fi

mkdir -p "$config_root"

if [ -L "$target" ] && [ "$(readlink "$target")" = "$script_dir" ]; then
  printf 'Конфигурация уже подключена: %s\n' "$target"
elif [ -e "$target" ] || [ -L "$target" ]; then
  backup="$target.backup.$(date +%Y%m%d-%H%M%S)"
  mv "$target" "$backup"
  printf 'Старая конфигурация сохранена в: %s\n' "$backup"
  ln -s "$script_dir" "$target"
  printf 'Создан симлинк: %s -> %s\n' "$target" "$script_dir"
else
  ln -s "$script_dir" "$target"
  printf 'Создан симлинк: %s -> %s\n' "$target" "$script_dir"
fi

printf '%s\n' 'Установка плагинов через lazy.nvim...'
nvim --headless '+Lazy! sync' +qa

printf '%s\n' 'Готово. Запусти nvim и дождись установки Treesitter-парсеров.'
