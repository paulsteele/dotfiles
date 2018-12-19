# Development Dot Files

## New Machine Set Up
```
git clone --separate-git-dir=$HOME/.myconf git@github.com:paulsteele/dotfiles.git $HOME/myconf-tmp
cp -r myconf-tmp/. ~
rm -rf myconf-tmp
source .zshrc
```

## External Dependencies
### Repos
* https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Cousine
* https://github.com/denysdovhan/spaceship-prompt
* https://github.com/majutsushi/urxvt-font-size
* https://github.com/EliverLara/Nordic
### Packages
* vim
* git
* i3
* rofi
* polybar
* lxappearance
* zsh
* oh-my-zsh
* uxrvt-unicode
* compton
* feh
* tig
