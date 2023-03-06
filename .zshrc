# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="spaceship"
# look at https://unicode-table.com for help with missing symbols
export SPACESHIP_PROMPT_ADD_NEWLINE=false
export SPACESHIP_PACKAGE_SYMBOL=" "
export SPACESHIP_DOCKER_SYMBOL=" "
export SPACESHIP_RUBY_SYMBOL=" "
export SPACESHIP_NODE_SYMBOL=" "
export SPACESHIP_AWS_SYMBOL=" "
export SPACESHIP_GOLANG_SYMBOL=" "
export SPACESHIP_KUBECONTEXT_SYMBOL=" "
export SPACESHIP_ASYNC_SHOW="false"
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  kubectl
  encode64
  sudo
)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
export EDITOR='nvim'
# Use ripgrep for fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case --glob "!.git/*"'
# fix gpg2 and sops
export GPG_TTY=$(tty)

#Universal Aliases
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'

