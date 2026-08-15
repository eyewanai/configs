# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$HOME/bin:$PATH"

export CLICOLOR=1
export LSCOLORS='exgxfxdxcxegedabagacad'
export LS_COLORS='di=34:ln=36:so=35:pi=33:ex=32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

autoload -Uz compinit
compinit
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:*:*:descriptions' format '%F{cyan}%d%f'

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats       ' %F{magenta}git:(%F{red}%b%F{magenta})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{magenta}git:(%F{red}%b%F{magenta}|%F{yellow}%a%F{magenta})%f'

setopt PROMPT_SUBST
PROMPT='%F{green}➜%f %F{blue}%1~%f${vcs_info_msg_0_} '

# >>> headroom persistent env >>>
export HEADROOM_PORT="8787"
export HEADROOM_HOST="127.0.0.1"
export HEADROOM_MODE="cache"
export HEADROOM_BACKEND="anthropic"
export HEADROOM_TELEMETRY="off"
export ANTHROPIC_BASE_URL="http://127.0.0.1:8787"
export ENABLE_TOOL_SEARCH="true"
export OPENAI_BASE_URL="http://127.0.0.1:8787/v1"
# <<< headroom persistent env <<<

# Create a separate tmux session when `tmux` is invoked without arguments.
# Explicit commands such as `tmux ls` keep their normal behavior.
tmux() {
  if (( $# == 0 )); then
    command tmux new-session
  else
    command tmux "$@"
  fi
}

eval "$(atuin init zsh)"
alias lg='lazygit'
