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
* https://github.com/junegunn/vim-plug
### Packages
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
* neovim
* ripgrep

### Linters
* https://github.com/amperser/proselint/
* https://github.com/koalaman/shellcheck
* http://www.mypy-lang.org/

### Setting up neovim
1. Install vim-plug `curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`
2. Run `:PlugInstall`

# Firefox Help
set in `about:config` `widget.content.gtk-theme-override = Adapta` if using Adapta-Nokoto

# ssh Help
https://gist.github.com/jexchan/2351996

# Mac Resources
* https://github.com/koekeishiya/yabai
* https://github.com/koekeishiya/skhd
* https://github.com/FelixKratz/SketchyBar
