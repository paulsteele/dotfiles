#My dot files

##Initial Set Up
```
git init --bare $HOME/.myconf
config config status.showUntrackedFiles no
```
Add alias to `.bashrc`
```
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
```

## New Machine Set Up
```
git clone --separate-git-dir=$HOME/.myconf /path/to/repo $HOME/myconf-tmp
mv -R $HOME/myconf-tmp ~
source .bashrc
config config status.showUntrackedFiles no
```