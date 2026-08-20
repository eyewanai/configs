# Neovim

Конфигурация рассчитана на Neovim 0.12+ и использует `lazy.nvim`.
Тема — Cinder, общая с kitty и Zed (см. корневой README).

## Зависимости

Обязательные — без них `install.sh` откажется работать:

- `nvim` 0.12 или новее;
- `git` — для установки `lazy.nvim` и плагинов;
- **C-компилятор** (`cc`, `gcc` или `clang`) — nvim-treesitter собирает
  парсеры из исходников на C. На свежей Linux-машине это самая частая причина
  вала ошибок при первом запуске: без компилятора падает сборка каждого языка
  из списка.

Дополнительные — без них Neovim запустится, но часть функций отключится:

- `rg` — поиск через Telescope;
- `go` и `gopls` — переходы и диагностика в Go;
- `lazygit` — открывается по `Space g g`;
- Nerd Font в терминале — иконки файлового дерева. Конфигурация kitty
  ожидает `Maple Mono NF`.

### Буфер обмена на Linux

В `init.lua` стоит `clipboard = "unnamedplus"`, но только если в системе есть
провайдер. На macOS он встроен, на Linux нужен один из:

```sh
wl-clipboard   # Wayland
xclip          # X11
xsel           # X11
```

Без провайдера настройка не включается — это сделано намеренно, иначе Neovim
печатает `clipboard: No provider` на каждое копирование.

### Пакеты

macOS:

```sh
brew install neovim ripgrep lazygit
brew install --cask font-maple-mono-nf
go install golang.org/x/tools/gopls@latest
```

Debian/Ubuntu:

```sh
sudo apt install neovim git build-essential ripgrep wl-clipboard
go install golang.org/x/tools/gopls@latest
```

Fedora:

```sh
sudo dnf install neovim git gcc make ripgrep wl-clipboard
```

Arch:

```sh
sudo pacman -S neovim git base-devel ripgrep wl-clipboard
```

`build-essential` / `base-devel` / `gcc` здесь и есть тот самый компилятор для
Treesitter. Neovim в репозиториях Debian и Ubuntu часто старее 0.12 — тогда
берите официальный AppImage или tarball с GitHub.

## Установка на новую машину

Склонировать репозиторий и выполнить из его корня:

```sh
./nvim/install.sh
```

Порядок работы скрипта:

1. проверяет обязательные зависимости и **прерывается до того, как что-либо
   тронуть**, если чего-то не хватает. Это защита от состояния, когда симлинк
   уже подменил конфигурацию, а плагины не встали;
2. сохраняет существующий `~/.config/nvim` в каталог с timestamp;
3. создаёт симлинк на каталог `nvim` этого репозитория;
4. ставит плагины из `lazy-lock.json`;
5. собирает Treesitter-парсеры и дожидается окончания сборки.

Шаги 4 и 5 не обрывают скрипт при ошибке: он доводит установку до конца и
показывает последние строки вывода вместе с путём к полному логу.

## Устройство

- `init.lua` — опции, плагины, LSP, горячие клавиши;
- `colors/cinder.lua` — тема;
- `lua/zed_ui.lua` — нижняя строка и хлебные крошки;
- `lua/languages.lua` — список языков для Treesitter. Он же используется
  скриптом установки, чтобы список не разъезжался с конфигурацией.

## Что не нужно переносить

Не коммитятся и не требуются для восстановления:

- `~/.local/share/nvim/lazy` — установленные плагины;
- `~/.local/share/nvim/site/parser` — скомпилированные парсеры;
- `~/.local/state/nvim` — логи, swap, история, shada;
- `~/.cache/nvim` — кэш Lua.

`lazy-lock.json` фиксирует версии плагинов, поэтому чистая установка
восстановит тот же набор.
