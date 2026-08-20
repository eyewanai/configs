# configs

Конфигурации рабочего окружения.

## Тема Cinder

Тёплый угольный фон `#1a1715` с акцентом ember `#ea904d`. Одна палитра на три
приложения, значения обязаны совпадать побайтово:

| | файл |
|---|---|
| kitty | `kitty/cinder.conf` |
| Zed | `zed/themes/cinder.json` |
| Neovim | `nvim/colors/cinder.lua` |

Акценты держатся в полосе воспринимаемой светлоты L\* 65–72 и дают контраст к
фону не ниже 4.5:1. Шрифт — `Maple Mono NF`, задаётся терминалом.

## Разделы

- [Neovim](nvim/README.md) — зависимости и установка на новую машину.
- `kitty/` — `kitty.conf` подключает `cinder.conf` строкой `include`.
- `zed/` — `settings.json` и тема в `themes/`.
- `yazi/`, `.tmux.conf`, `.zshrc`, `.aerospace.toml` — остальное окружение.

## Установка

Для Neovim есть скрипт: `./nvim/install.sh`.

kitty и Zed переносятся копированием или симлинком — пути совпадают на macOS
и на Linux:

```sh
ln -s "$PWD/kitty" ~/.config/kitty
ln -s "$PWD/zed"   ~/.config/zed
```

Учтите, что `kitty/kitty.conf` — полный дамп настроек kitty с комментариями,
а все правки темы лежат в `cinder.conf`, который подключается в конце файла.
