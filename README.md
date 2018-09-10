# My dot files

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
### Packages
* vim
* git
* i3
* rofi
* polybar
* lxappearance
* adapta-gtk-theme
* zsh
* oh-my-zsh
