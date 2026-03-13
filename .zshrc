# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Preferred editor for local and remote sessions
export EDITOR='nvim'
# Use ripgrep for fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case --glob "!.git/*"'
# fix gpg2 and sops
export GPG_TTY=$TTY

#Universal Aliases
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
alias mov-to-gif="find . -name \"*.mov\" -maxdepth 1 -type f -exec sh -c 'ffmpeg -i \"{}\" -pix_fmt rgb32 -r 10 -vf scale=720:-1 \"{}.output.gif\" && magick -layers Optimize \"{}.output.gif\" \"{}.optimized.gif\" && rm \"{}.output.gif\" ' \\;"
alias mp4-to-gif="find . -name \"*.mp4\" -maxdepth 1 -type f -exec sh -c 'ffmpeg -i \"{}\" -pix_fmt rgb32 -r 10 -vf scale=720:-1 \"{}.output.gif\" && magick -layers Optimize \"{}.output.gif\" \"{}.optimized.gif\" && rm \"{}.output.gif\" ' \\;"

bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

zinit ice depth=1; zinit light romkatv/powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

zinit ice wait lucid as"completion"
zinit snippet "$BUN_INSTALL/_bun"

zinit ice wait lucid atload'
  alias k=kubectl
  kubectl() {
    unfunction kubectl
    source <(command kubectl completion zsh)
    compdef k=kubectl
    command kubectl "$@"
  }
' id-as"kubectl-lazy"
zinit light zdharma-continuum/null

zinit wait lucid for \
  blockf atinit"zicompinit; zicdreplay; compdef config=git" \
    zsh-users/zsh-completions \
  atload"
    zstyle ':completion:*:git-checkout:*' sort false
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':completion:*' list-colors \${(s.:.)LS_COLORS}
    zstyle ':completion:*' menu no
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always \$realpath'
    zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
    zstyle ':fzf-tab:*' use-fzf-default-opts yes
    zstyle ':fzf-tab:*' switch-group '<' '>'
  " \
    Aloxaf/fzf-tab \
  atload"_zsh_autosuggest_start; bindkey '^[[Z' autosuggest-accept" \
    zsh-users/zsh-autosuggestions \
  atload"bindkey '^[[A' history-substring-search-up; bindkey '^[[B' history-substring-search-down" \
    zsh-users/zsh-history-substring-search \
    zdharma-continuum/fast-syntax-highlighting
