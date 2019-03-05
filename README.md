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
* uxrvt-unicode
* compton
* feh
* tig
* pywal (pip3 install pywal --user)

### Setting up bacgkround
1. Download images from onedrive (personal)
2. Navigate to `~/.config/feh/timed-backgrounds`
3. Run `./install.sh`
