# nix-env -f ~/.nixpkgs/my-packages.nix -ir
with import <nixpkgs> {};
[
vim
gitAndTools.git-annex
mr
vcsh
gitFull
(conky.override { x11Support = false; })
fossil
gitAndTools.gitRemoteGcrypt
dwm dmenu xlockmore xautolock xorg.xset xorg.xinput xorg.xsetroot xorg.setxkbmap xorg.xmodmap rxvt_unicode st
asciidoc
baobab
bup
cabal2nix
ctags
direnv
doxygen
dvtm
ftop
gnumake
gnuplot
iotop
jq
mkpasswd
mr
nix-repl
nox
paraview
pmount
pstree
python
ruby
screen
teamviewer
tig
vagrant
valgrind
vcsh
virtualgl
mosh
xpra
aria2
nixops
chromium
htop
tree
gnupg
x2goclient
wpsoffice
]
