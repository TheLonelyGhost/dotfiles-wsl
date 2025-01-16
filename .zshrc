if [ -x /usr/local/bin/starship ]; then
  eval "$(/usr/local/bin/starship init zsh)"
fi

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2

if [ -x /usr/bin/dircolors ]; then
  eval "$(dircolors -b)"
fi

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

alias ls='command ls --classify --human-readable --hide-control-chars --quoting-style=shell --color=auto'


#================================#
# === BEGIN RIG BOOTSTRAPPER === #

function rig() {
  __rig-clear
  command rig "$@"
  source "${RIG_ALIAS_FILE:-/tmp/rig-aliases}"
}
function __rig-clear() {
  local alias_count
  if [ -e "${RIG_ALIAS_FILE}.count" ]; then
	alias_count="$(cat "${RIG_ALIAS_FILE}.count")"
  fi
  if [ "$alias_count" -eq 0 ]; then return 0; fi

  for i in $(seq $alias_count); do
    unalias "${RIG_ALIAS_PREFIX}${i}"
  done

  echo 0 > "${RIG_ALIAS_FILE}.count"
}
: "${RIG_ALIAS_PREFIX:=e}"
: "${RIG_ALIAS_FILE:=/tmp/rig-aliases}"

# ==== END RIG BOOTSTRAPPER ==== #
#================================#

# vim: ft=zsh
