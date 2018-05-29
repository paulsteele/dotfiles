# My dot files

## Initial Set Up
```
git init --bare $HOME/.myconf
```
Add alias to `.bashrc`
```
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
```

## New Machine Set Up
```
git clone --separate-git-dir=$HOME/.myconf git@github.com:paulsteele/dotfiles.git $HOME/myconf-tmp
cp myconf-tmp/* ~
rm -rf myconf-tmp
source .bashrc
```

## External Dependencies
### Repos
* https://github.com/powerline/fonts
### Packages
* i3
* rofi
* polybar
* adapta-gtk-theme
* zsh
* oh-my-zsh
* powerline-fonts
